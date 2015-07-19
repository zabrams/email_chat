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
	var new_body = "";
	if (matched_body = body.match(/(.*?)<div class=\"gmail_extra\">/m)) {
	    new_body = matched_body[0];
	}
	else {
	    new_body = body;
	}
	return new_body;
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
