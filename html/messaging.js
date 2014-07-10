/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

Messaging = {
    registerHandler: function (name, handler) {
        document.addEventListener(name, function (event) {
            handler(event.detail);
        });
    },

    sendMessage: function (command, arguments) {
        var message = JSON.stringify([command, arguments]);
        document.title = message;
    },
}

