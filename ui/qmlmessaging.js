/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

var handlers = {"Log": function (message) { console.log(message); } };

function registerHandler(name, handler) {
    handlers[name] = handler;
}

function handleMessage(message) {
    if (message === "")
        return;

    var command = JSON.parse(message);
    var handler = handlers[command[0]];
    if (handler === undefined)
        console.log("No handler for " + command[0]);
    else
        handler(command[1]);
}

function sendMessage(command, arguments) {
    var message = JSON.stringify([command, arguments]).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    bookWebView.experimental.evaluateJavaScript("Messaging.handleMessage('" + message + "')");
}
