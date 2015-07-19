var UpperNav = React.createClass({
  render: function() {
    return (
    	<header className="bar bar-nav">
			<a className="icon icon-refresh pull-left"></a>
			<a className="icon icon-compose pull-right"></a>
			<h1 className="title">
				Inbox
			</h1>
		</header>
    );
  }
});

var ParticipantCircle = React.createClass({
	render: function() {
    	return (
    		<div className="name-image media-object pull-left">
    			<div className="one"> <p>{getInitials(this.props.email.from)}</p> </div>
    		</div>
    	);
    }
});

var ThreadLoading = React.createClass({
	render: function() {
		return (
			<div className="typing-indicator">
			  <span></span>
			  <span></span>
			  <span></span>
			</div>
		);
	}
});

var MessageDetail = React.createClass({
	render: function() {
		return (
			<div>
				<div className="card timecard">
					<p className="msg-time"> {displayDate(this.props.email[1].date)} </p>
				</div>
				<div className="card">
					<li className="msg-view-cell">
						<div className="msg-header">
							<p className="msg-from"> {getName(this.props.email[1].from)} </p>
							<p>
								 | {this.props.email[1].all_recip}
							</p>
						</div>
						<div dangerouslySetInnerHTML={{__html: removeHistory(this.props.email[1].body)}} />
					</li>
				</div>
			</div>
		);
	}
});

var MessageSummary = React.createClass({
  viewThread: function() {
  	this.props.onUserClick(
  		this.props.email
  	);
  	console.log(this.props.email)
  },
  render: function() {
    var length = this.props.email.length;
    var display_email = this.props.email[length-1];
    return (
		<li className="table-view-cell media">
			<a className="email-summary" onClick={this.viewThread}>
				<ParticipantCircle email={display_email[1]} />
				<div className="media-body">
					<p> {display_email[1].subject} | {getName(display_email[1].from)} </p>
					<p> {display_email[1].snippet} </p>
				</div>
			</a>
		</li>
	);
  }
});


var ContentPadded = React.createClass({
  render: function() {
    return (
    	<div className="content">
      		<div className="content-padded">
		    	{this.props.children}
		    </div>
		</div>
    );
  }
});

var MessageBody = React.createClass({
  render: function() {
    console.log(this.props)
    var rows = [];

    /* Maybe switch below to use map */
    if (!this.props.chatView) {
	    this.props.emails.forEach(function(email){
		    for (var key in email) {
		    	if (email.hasOwnProperty(key)) {
		    		rows.push(<MessageSummary email={email[key]} key={key} onUserClick={this.props.onUserClick} />);
		    	}
		    }
		}.bind(this));
	    return (
	    	<ContentPadded>
		    	<ul className="table-view">
		    		{rows}
				</ul>
			</ContentPadded>
		);
			    	
	}
	if (this.props.chatView) {
		rows.push(<MessageSummary email={this.props.chatView} onUserClick={this.props.onUserClick} />);
		var messages = [];
		this.props.chatView.forEach(function(email){
			messages.push(<MessageDetail email={email} key={email[0]} />);
		}.bind(this));
		return (
	    	<ContentPadded>
		    	<ul className="table-view">
		    		{rows}
				</ul>
		    	<ul className="msg-view">
		    		{messages}
		    	</ul>
		    </ContentPadded>
	    );
	}
  }
});

/*
var Message = React.createClass({
  render: function() {
    return (
    	<li className="msg-view-cell"> 
	    	<div className="msg-header">
				<p className="msg-from"> {this.props.from} </p>
				<p className="msg-hour">| {this.props.date}</p>
				<p className="msg-day"> {this.props.date} </p>
			</div>
			<div className="msg-header">
				<p className="msg-day">{this.props.participants}</p>
			</div>
			{this.props.body}
		</li>
	);
  }
});
*/

var EmailApp = React.createClass({
  getInitialState: function() {
  	return {
  		chatView: "",
  		emails: [],
  	};
  },
  componentDidMount: function () {
    this.loadMessagesFromServer();
  },
  loadMessagesFromServer: function () {
  	$.ajax({
      url: this.props.url,
      dataType: 'json',
      success: function (emails) {
        this.setState({emails: emails});
      }.bind(this),
      error: function (xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  handleClick: function(email) {
  	if (this.state.chatView === '') {
	  	this.setState({
	  		chatView: email,
	  	});
	}
	else {
		this.setState({
	  		chatView: "",
	  	});
	}
  },
  render: function() {
    return (
    	<div>
	    	<UpperNav />
	    	<MessageBody emails={this.state.emails} chatView={this.state.chatView} onUserClick={this.handleClick} />
	    </div>
    );
  }
});

var EMAILS = [
	{"14ea22e0b4d65f1e":
		{"threadId":"14ea22e0b4d65f1e",
		"labels":["INBOX","CATEGORY_FORUMS","UNREAD"],
		"subject":"Fwd: R12 pre-order: Week 6 update",
		"from":"Jack Dorsey \u003cjack@squareup.com\u003e",
		"snippet":"Team, happy Saturday and if you\u0026#39;re in SF I\u0026#39;ll see you at the picnic soon. Thought this was",
		"body":"Team, happy Saturday and if", 
		"date":"Sat, 18 Jul 2015 10:19:18 -0700",
		"to":"Square \u003cteam@squareup.com\u003e",
		"cc":null,
		"all_recip":"Jack Dorsey, Square"
		},
	"14dd5a86b9668a5a":
		{"threadId":"14dd5a86b9668a5a",
		"labels":["INBOX","CATEGORY_PERSONAL"],
		"subject":"Fwd: Intercom on Customer Engagment",
		"from":"Collin Wikman \u003ccollin@squareup.com\u003e",
		"snippet":"---------- Forwarded message --------- From: Jimmy Nelson \u0026lt;jnelson@squareup.com\u0026gt; Date: Mon, Jun",
		"body":"\u003cdiv dir=\"ltr\"\u003e\u003cbr\u003e\u003cbr\u003e\u003cdiv class=\"gmail_quote\"\u003e\u003cdiv dir=\"ltr\"\u003e---------- Forwarded message ---------\u003cbr\u003eFrom: Jimmy Nelson \u0026lt;\u003ca href=\"mailto:jnelson@squareup.com\"\u003ejnelson@squareup.com\u003c/a\u003e\u0026gt;\u003cbr\u003eDate: Mon, Jun 8, 2015 at 1:45 PM\u003cbr\u003eSubject: Intercom on Customer Engagment\u003cbr\u003eTo: Collin Wikman \u0026lt;\u003ca href=\"mailto:collin@squareup.com\"\u003ecollin@squareup.com\u003c/a\u003e\u0026gt;, Nathan Hills \u0026lt;\u003ca href=\"mailto:nathanhills@squareup.com\"\u003enathanhills@squareup.com\u003c/a\u003e\u0026gt;, Dave Johannes \u0026lt;\u003ca href=\"mailto:dave@squareup.com\"\u003edave@squareup.com\u003c/a\u003e\u0026gt;\u003cbr\u003e\u003c/div\u003e\u003cbr\u003e\u003cbr\u003e\u003cdiv dir=\"ltr\"\u003eA-Yo!\u003cdiv\u003e\u003cbr\u003e\u003c/div\u003e\u003cdiv\u003eIntercom did a smart \u003ca href=\"https://medium.com/@intercom/how-to-educate-and-persuade-customers-11a975751e8b\" target=\"_blank\"\u003elittle Medium post\u003c/a\u003e on \u0026#39;How to Educate and Persuade Customers\u0026#39; which was a teaser for a larger pdf book (\u003ca href=\"https://www.intercom.io/books/customer-engagement?utm_medium=article\u0026amp;utm_source=medium\u0026amp;utm_campaign=ce-book-medium#download\" target=\"_blank\"\u003eIntercom on customer engagement\u003c/a\u003e) that you can download for free if you give them your email.\u003cbr\u003e\u003cbr\u003eI attached the pdfactually a good read i suggest you guys check out.\u003c/div\u003e\u003cdiv\u003e\u003cbr\u003e\u003c/div\u003e\u003cdiv\u003e\u003cbr\u003e\u003c/div\u003e\u003c/div\u003e\u003c/div\u003e\u003c/div\u003e",
		"date":"Tue, 09 Jun 2015 00:11:20 +0000",
		"to":"Zach Abrams \u003czabrams@squareup.com\u003e",
		"cc":null
		}
	}

];

var ready = function () {
  React.render(
    <EmailApp url="/messages.json"/>,
    document.getElementById('inbox')
  );
};

$(document).ready(ready);