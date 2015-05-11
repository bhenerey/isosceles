$('.node-name').click(
  function() {
  console.log('clicked');
  console.log(this);
  $(this).siblings('.node-info').toggle();
  }
);
