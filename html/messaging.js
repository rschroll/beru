/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

Messaging = {
    handlers: Object(),

    registerHandler: function (name, handler) {
        Messaging.handlers[name] = handler;
    },

    handleMessage: function (message) {
        var command = JSON.parse(message);
        var handler = Messaging.handlers[command[0]];
        if (handler === undefined)
            Messaging.sendMessage("Log", "WebView: No handler for " + command[0]);
        else
            handler(command[1]);
    },

    sendMessage: function (command, arguments) {
        var message = JSON.stringify([command, arguments]);
        document.title = message;
    },
}

