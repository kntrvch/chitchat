{% extends 'layout.swig' %} 
{% block content %}
  <div class="container">
    
    <div class="row">
      <div class="col-md-9"> 
<div class="jumbotron">
  <h1 class="display-3">Welcome to chitchat!</h1>
  <p class="lead">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. </p>
  <hr class="my-4">
  <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>
  <p class="lead">
    <a class="btn btn-primary btn-lg" href="/new" role="button">Create new</a>
  </p>
</div>
      </div>
      <div class="col-md-3">
      <ul class="list-group">

  {% for thread in threads %}
      <li class="list-group-item d-flex justify-content-between align-items-center">
    <a href="/{{thread.code}}">{{thread.code}}</a>
    <span class="trend-line">{{thread.trending}}</span>
    <span class="badge badge-primary badge-pill">{{thread.messages.length}}</span>
  </li>
{% endfor %}
</ul>
      </div>
    </div>
  </div>

{% endblock %}

  {% block javascripts %}
  <script>
  $(function() {

$(".trend-line").sparkline('html', {
    type: 'line',
    width: '30',
    lineColor: '#38b44a',
    fillColor: '#fff',
    lineWidth: 2,
    spotColor: '#38b44a',
    minSpotColor: '#38b44a',
    maxSpotColor: '#38b44a',
    highlightSpotColor: '#38b44a',
    highlightLineColor: '#38b44a',
    spotRadius: 1,
    drawNormalOnTop: false, 
    disableTooltips: true, 
    disableHighlight: true, 
    disableInteraction: true
});

  });
  </script>
  {% endblock %}