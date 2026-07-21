"""Order/chaos presets: bundles of option values applied in generate_early.

A preset only fills options the player left at their class default, so any option
set explicitly in the YAML always wins. `order` matches the plain defaults (so it
is effectively a no-op); `chaos` cranks the disruptive knobs.
"""

# option attribute name -> value to apply. Values use the option's raw form
# (Choice -> option int/key, Toggle/Range -> int, OptionSet -> set).
PRESETS = {
    "order": {
        # the curated defaults; listed for clarity, all equal to class defaults
        "goal": "godcat",
        "check_percentage": 100,
        "trap_percentage": 10,
        "death_link": 0,
        "difficulty": "normal",
    },
    "chaos": {
        "goal": "check_percent",
        "check_percentage": 40,
        "trap_percentage": 40,
        "trap_types": {"encounter", "statdown"},
        "death_link": 1,
        "difficulty": "hard",
    },
}


def apply(options):
    """Apply the chosen preset to `options` for every option still at its default."""
    preset_key = options.preset.current_key
    if preset_key not in PRESETS:
        return
    for attr, value in PRESETS[preset_key].items():
        opt = getattr(options, attr)
        # only fill in options the player left untouched (== class default)
        if opt.value != type(opt).default:
            continue
        if isinstance(value, str) and hasattr(type(opt), f"option_{value}"):
            opt.value = getattr(type(opt), f"option_{value}")
        elif isinstance(value, (set, frozenset)):
            opt.value = set(value)
        else:
            opt.value = value
