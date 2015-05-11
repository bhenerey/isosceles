$.ajax({
  type: "GET",
  url: "http://sensu.prod.opinionlab.com:8080/events",
  dataType: 'json',
  async: true,
  crossDomain: true,
  beforeSend: function (xhr) {
    xhr.setRequestHeader("Authentication", "Basic " + btoa('admin:secret'));
  },
  success: function (){
    console.log('connected to sensu');
  }
});
