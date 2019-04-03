<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width">
  <title>{{ title }}</title>
  <link rel="icon" href="img/favicon.png">
  <link href="https://maxcdn.bootstrapcdn.com/bootswatch/4.0.0/united/bootstrap.min.css" rel="stylesheet" media="screen, print">
  <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
  <style>
    body {
      padding-top: 75px;
    }
    #mainWrapper {
      display: none;
    }
    .message-in .alert {
      text-align: right;
      float: right;
      margin-bottom: 5px;
    }
    .message-out .alert {
      text-align: left;
      float: left;
      margin-bottom: 5px;
    }
    .message-in {
      text-align: right;
      margin-bottom: 10px;
    }
    .message-out {
      text-align: left;
      margin-bottom: 10px;
    }
    .message-out .alert p, 
    .message-in .alert p {
      text-align: justify;
    }
    .message-out small, 
    .message-in small {
      font-size: 60%;
      clear: both;
      display: block;
      color: #acacac;
    }
    .message-wrapper {
      width: 100%;
      clear: both;
    }
    #chatWindow {
      padding-right: 15px;
    }

    .jumbotron {
      padding: 2rem;
    }

    .status-icon {
      display: none;
      color: #acacac !important;
    } 
    .typing-note {
      display: none;
      font-size: 11px;
      color: #acacac;
    }
    #toneAnalyzerWindow {
      width: 100%;
      height: 300px;
      overflow: auto;
    }
    #toneAnalyzerWindow .tone {
      text-transform: lowercase;
    }
    pre {
      counter-reset: line-numbering;
      background: #2c3e50;
      padding: 12px;
      width: 600px;
      color: #ecf0f1;
      line-height: 100%;
    }
  </style>
</head>
<body>
<div class="navbar navbar-expand-lg fixed-top navbar-dark bg-primary">
      <div class="container">
        <a href="/" class="navbar-brand">chitchat</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarResponsive">
          <ul class="nav navbar-nav ml-auto">
            <li class="nav-item">
              <a id="saveThreadButton_" href="/new" class="btn btn-success" >New</a>
            </li>
          </ul>

        </div>
      </div>
    </div>
  {% block content %}
  {% endblock %}
<footer class="my-5 pt-5 text-muted text-center text-small">
        <p class="mb-1">© 2018 chitchat</p>
        <ul class="list-inline">
          <li class="list-inline-item"><a href="#">Privacy</a></li>
          <li class="list-inline-item"><a href="#">Terms</a></li>
          <li class="list-inline-item"><a href="#">Support</a></li>
        </ul>
      </footer>
      
      <script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.13.0/umd/popper.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/2.1.1/socket.io.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jQuery-slimScroll/1.3.8/jquery.slimscroll.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.5.10/clipboard.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-sparklines/2.1.2/jquery.sparkline.min.js"></script>

  {% block javascripts %}{% endblock %}
</body>
</html>
