oxide.addMessageHandler("MESSAGE", function (msg) {
    var event = new CustomEvent(msg.args.command, {detail: msg.args.arguments});
    document.dispatchEvent(event);
    msg.reply({});
});
