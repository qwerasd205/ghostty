const std = @import("std");
const Allocator = std.mem.Allocator;

/// A bitmask for all key modifiers. This is taken directly from the
/// GLFW representation, but we use this generically.
///
/// IMPORTANT: Any changes here update include/ghostty.h
pub const Mods = packed struct(Mods.Int) {
    pub const Int = u10;

    shift: Side = .none,
    ctrl: Side = .none,
    alt: Side = .none,
    super: Side = .none,
    caps_lock: bool = false,
    num_lock: bool = false,

    /// Keeps track of left/right press. A packed struct makes it easy
    /// to set as a bitmask and then check the individual values.
    pub const Side = enum(u2) {
        none = 0,
        left = 1,
        right = 2,

        /// Note that while this should only be set for BOTH being set,
        /// this is semantically used to mean "any" for the purposes of
        /// keybindings. We do not allow keybindings to map to "both".
        both = 3,

        /// Returns true if the key is pressed at all.
        pub fn pressed(self: Side) bool {
            return @intFromEnum(self) != 0;
        }
    };

    /// Return the identical mods but with all directional configuration
    /// removed and all of it set to "both".
    pub fn removeDirection(self: Mods) Mods {
        return Mods{
            .shift = if (self.shift.pressed()) .both else .none,
            .ctrl = if (self.ctrl.pressed()) .both else .none,
            .alt = if (self.alt.pressed()) .both else .none,
            .super = if (self.super.pressed()) .both else .none,
            .caps_lock = self.caps_lock,
            .num_lock = self.num_lock,
        };
    }

    // For our own understanding
    test {
        const testing = std.testing;
        try testing.expectEqual(@as(Int, @bitCast(Mods{})), @as(Int, 0b0));
        try testing.expectEqual(
            @as(Int, @bitCast(Mods{ .shift = .left })),
            @as(Int, 0b0000_0001),
        );
    }
};

/// The action associated with an input event. This is backed by a c_int
/// so that we can use the enum as-is for our embedding API.
///
/// IMPORTANT: Any changes here update include/ghostty.h
pub const Action = enum(c_int) {
    release,
    press,
    repeat,
};

/// The set of keys that can map to keybindings. These have no fixed enum
/// values because we map platform-specific keys to this set. Note that
/// this only needs to accomodate what maps to a key. If a key is not bound
/// to anything and the key can be mapped to a printable character, then that
/// unicode character is sent directly to the pty.
///
/// This is backed by a c_int so we can use this as-is for our embedding API.
///
/// IMPORTANT: Any changes here update include/ghostty.h
pub const Key = enum(c_int) {
    invalid,

    // a-z
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,

    // numbers
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,

    // puncuation
    semicolon,
    space,
    apostrophe,
    comma,
    grave_accent, // `
    period,
    slash,
    minus,
    equal,
    left_bracket, // [
    right_bracket, // ]
    backslash, // /

    // control
    up,
    down,
    right,
    left,
    home,
    end,
    insert,
    delete,
    caps_lock,
    scroll_lock,
    num_lock,
    page_up,
    page_down,
    escape,
    enter,
    tab,
    backspace,
    print_screen,
    pause,

    // function keys
    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    f13,
    f14,
    f15,
    f16,
    f17,
    f18,
    f19,
    f20,
    f21,
    f22,
    f23,
    f24,
    f25,

    // keypad
    kp_0,
    kp_1,
    kp_2,
    kp_3,
    kp_4,
    kp_5,
    kp_6,
    kp_7,
    kp_8,
    kp_9,
    kp_decimal,
    kp_divide,
    kp_multiply,
    kp_subtract,
    kp_add,
    kp_enter,
    kp_equal,

    // modifiers
    left_shift,
    left_control,
    left_alt,
    left_super,
    right_shift,
    right_control,
    right_alt,
    right_super,

    // To support more keys (there are obviously more!) add them here
    // and ensure the mapping is up to date in the Window key handler.
};
