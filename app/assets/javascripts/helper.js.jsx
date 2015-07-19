function getName(from) {
	return from.replace(/<.*?>|["()]/, "").trim().replace(/\A"|"\Z/, '');
};

function getInitials(from) {
	var initials = "";
	var name = getName(from).split(" ");
	name.forEach(function(name) {
		initials += name.charAt(0).toUpperCase();
	});
	return initials.slice(0,2);
};

function removeHistory(body) {
	var newBody = "";
	if (matchedBody = body.match(/(.*?)<div class=\"gmail_extra\">|(.*?)<div class=\"gmail_quote\">/m)) {
	    newBody = matchedBody[0];
	    if (matchMailto = matchedBody[0].match(/(.*?)Sent:|(.*?)wrote:/m)) {
	    	newBody = matchMailto[0];
	    }
	}
	else if (matchMailto = body.match(/(.*?)Sent:|(.*?)wrote:/m)) {
		newBody = matchMailto[0];
	}
	else {
	    newBody = body;
	}
	return newBody;
}

function displayDate(string) {
	var date = new Date(string);
	var options = {
	    hour: "2-digit", minute: "2-digit", 
	    weekday: "long", year: "numeric", 
	    month: "short", day: "numeric",
	};
	present_date = date.toLocaleTimeString("en-us", options);
	return present_date;
}
