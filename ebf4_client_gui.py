"""Tkinter front end for the EBF4 Archipelago client.

Stdlib only (tkinter) — no Kivy, no Archipelago Launcher, so it runs as its own
process and can't collide with anything. `ebf4_client.py` calls run_gui() when
started with no arguments.

The asyncio client runs on a background thread; log lines and the game-connection
indicator are marshalled back to the Tk main thread with root.after.
"""
import asyncio
import queue
import threading
import tkinter as tk
from tkinter import scrolledtext, ttk

DEFAULT_SERVER = "localhost:38281"
TOOLS = ["Axe", "Candle", "Hammer", "Leafy Boots",
         "Step Ladder", "Thermal Boots", "Winged Boots"]


def run_gui(client_factory, default_game_port):
    root = tk.Tk()
    root.title("EBF4 Client")
    root.minsize(460, 360)

    logq = queue.Queue()
    state = {"client": None, "loop": None, "thread": None}

    frm = ttk.Frame(root, padding=8)
    frm.pack(fill="both", expand=True)
    frm.columnconfigure(1, weight=1)

    ttk.Label(frm, text="Server").grid(row=0, column=0, sticky="w")
    server_var = tk.StringVar(value=DEFAULT_SERVER)
    ttk.Entry(frm, textvariable=server_var).grid(row=0, column=1, sticky="ew", columnspan=2)

    ttk.Label(frm, text="Slot").grid(row=1, column=0, sticky="w")
    slot_var = tk.StringVar()
    ttk.Entry(frm, textvariable=slot_var).grid(row=1, column=1, sticky="ew", columnspan=2)

    ttk.Label(frm, text="Password").grid(row=2, column=0, sticky="w")
    pass_var = tk.StringVar()
    ttk.Entry(frm, textvariable=pass_var, show="*").grid(row=2, column=1, sticky="ew", columnspan=2)

    status_var = tk.StringVar(value="game: ○")  # ○ open / ● connected
    status_lbl = ttk.Label(frm, textvariable=status_var)
    status_lbl.grid(row=3, column=2, sticky="e")

    log = scrolledtext.ScrolledText(frm, height=14, state="disabled", wrap="word")
    log.grid(row=4, column=0, columnspan=3, sticky="nsew", pady=(6, 0))
    frm.rowconfigure(4, weight=1)

    cmd_var = tk.StringVar()
    cmd_entry = ttk.Entry(frm, textvariable=cmd_var)
    cmd_entry.grid(row=5, column=0, columnspan=3, sticky="ew", pady=(4, 0))

    def append(line):
        log.configure(state="normal")
        log.insert("end", line + "\n")
        log.see("end")
        log.configure(state="disabled")

    def sink(line):
        logq.put(line)

    def start():
        if state["thread"] and state["thread"].is_alive():
            return
        server = server_var.get().strip()
        slot = slot_var.get().strip()
        if not server or not slot:
            append("enter a server and slot name first")
            return
        client = client_factory(server, slot, pass_var.get(), default_game_port, sink)
        state["client"] = client
        connect_btn.configure(text="Disconnect")

        def worker():
            loop = asyncio.new_event_loop()
            state["loop"] = loop
            asyncio.set_event_loop(loop)
            try:
                loop.run_until_complete(client.run())
            except Exception as e:
                logq.put(f"stopped: {e}")
            finally:
                loop.close()
                state["loop"] = None

        t = threading.Thread(target=worker, daemon=True)
        state["thread"] = t
        t.start()

    def stop():
        loop = state["loop"]
        if loop:
            loop.call_soon_threadsafe(loop.stop)
        connect_btn.configure(text="Connect")

    def toggle():
        if state["thread"] and state["thread"].is_alive():
            stop()
        else:
            start()

    connect_btn = ttk.Button(frm, text="Connect", command=toggle)
    connect_btn.grid(row=3, column=0, sticky="w", pady=(6, 0))

    def grant(name):
        c, loop = state["client"], state["loop"]
        if c and loop:
            asyncio.run_coroutine_threadsafe(c.grant_tool(name), loop)
        else:
            append("connect first")

    def run_command(_event=None):
        line = cmd_var.get().strip()
        if not line:
            return
        cmd_var.set("")
        c, loop = state["client"], state["loop"]
        if c and loop:
            append(f"> {line}")
            asyncio.run_coroutine_threadsafe(c.handle_command(line), loop)
        else:
            append("connect first")

    cmd_entry.bind("<Return>", run_command)

    tool_btn = ttk.Menubutton(frm, text="Grant tool ▾")
    tool_menu = tk.Menu(tool_btn, tearoff=0)
    for _t in TOOLS:
        tool_menu.add_command(label=_t, command=lambda n=_t: grant(n))
    tool_btn["menu"] = tool_menu
    tool_btn.grid(row=3, column=1, sticky="w", pady=(6, 0))

    def pump():
        while True:
            try:
                append(logq.get_nowait())
            except queue.Empty:
                break
        c = state["client"]
        alive = bool(state["thread"] and state["thread"].is_alive())
        game = bool(c and getattr(c, "game_writer", None))
        server = bool(c and getattr(c, "ws", None))
        if game:
            status_var.set("game: ●"); color = "#2e7d32"      # green: game linked
        elif server or alive:
            status_var.set("server: ●"); color = "#f9a825"    # amber: server only
        else:
            status_var.set("game: ○"); color = "#c62828"      # red: offline
        try:
            status_lbl.configure(foreground=color)
        except tk.TclError:
            pass
        connect_btn.configure(text="Disconnect" if alive else "Connect")
        root.after(200, pump)

    root.after(200, pump)
    root.mainloop()
