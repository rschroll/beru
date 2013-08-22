/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

.pragma library

function History(func) {
    this.stack = Array();
    this.loc = 0;
    this.onChanged = func;
}

// Replace the current location on the stack with curr, add next, and
// move the location to next.  Thus, the stack is keeping track of
// where jumps left from.  The exception is the top, which tracks where
// the last jump landed.
History.prototype.add = function (curr, next) {
    this.stack.splice(this.loc, this.stack.length, curr, next);
    this.loc += 1;
    this.callback();
}

History.prototype.clear = function () {
    this.stack = Array();
    this.loc = 0;
    this.callback();
}

History.prototype.goForward = function () {
    if (this.loc == this.stack.length - 1)
        return null;
    this.loc += 1;
    this.callback();
    return this.stack[this.loc];
}

History.prototype.goBackward = function () {
    if (this.loc <= 0)
        return null;
    this.loc -= 1;
    this.callback();
    return this.stack[this.loc];
}

History.prototype.canForward = function () {
    return this.loc < this.stack.length - 1;
}

History.prototype.canBackward = function () {
    return this.loc > 0;
}

History.prototype.callback = function () {
    if (this.onChanged !== null)
        this.onChanged(this.canBackward(), this.canForward());
}
