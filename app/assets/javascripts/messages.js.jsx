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
					<p className="msg-time"> 8:23pm | {this.props.email.date} </p>
				</div>
				<div className="card">
					<li className="msg-view-cell">
						<div className="msg-header">
							<p className="msg-from"> {getName(this.props.email.from)} </p>
							<p>
								 | {this.props.email.all_recip}
							</p>
						</div>
						{this.props.email.body}
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
    return (
		<li className="table-view-cell media">
			<a className="email-summary" onClick={this.viewThread}>
				<ParticipantCircle email={this.props.email} />
				<div className="media-body">
					<p> {this.props.email.subject} | {getName(this.props.email.from)} </p>
					<p> {this.props.email.snippet} </p>
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
	    	rows.push(<MessageSummary email={email} key={email.threadId} onUserClick={this.props.onUserClick} />);
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
		rows.push(<MessageSummary email={this.props.chatView} key={this.props.chatView.threadId} onUserClick={this.props.onUserClick} />);
		return (
	    	<ContentPadded>
		    	<ul className="table-view">
		    		{rows}
				</ul>
		    	<ul className="msg-view">
		    		<MessageDetail email={this.props.chatView} />
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
  		chatView: '',
  		emails: '',
  	};
  },
  componentWillMount: function () {
    this.loadCommentsFromServer();
  },
  loadCommentsFromServer: function () {
  	this.setState({
  		emails: EMAILS,
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
	  		chatView: '',
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
	{threadId: 123456, labels: ["UNREAD", "IMPORTANT"], subject: 'Subject 1', from: 'Zach Abrams <zachary.abrams@gmail.com>',
      snippet:  'This is a snippet', body: 'Lorem ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum', 
      date:  'June 21, 1985', to: 'Zach Abrams <zabrams@squareup.com>', cc: "James James <james@jones.com>, Kim Jun <kim@jun.com>", 
      all_recip: "Zach Abrams, James Jones, Kim Jun"},
      {threadId: 12344566, labels: ["UNREAD", "IMPORTANT"], subject: 'Subject 2', from: 'Zach Abrams <zachary.abrams@gmail.com>',
      snippet:  'This is a snippet', body: 'Lorem ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum ipsum', 
      date:  'June 21, 1985', to: '<zabrams@squareup.com>', cc: "James James <james@jones.com>, Kim Jun <kim@jun.com>",
  	  all_recip: "Zach Abrams, James Jones, Kim Jun"}
];

var ready = function () {
  React.render(
    <EmailApp />,
    document.getElementById('inbox')
  );
};

$(document).ready(ready);