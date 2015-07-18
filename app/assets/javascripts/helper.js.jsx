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
