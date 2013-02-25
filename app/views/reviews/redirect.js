$('#myModal .modal-body').html("Review created successfully!")
$('#newreviewform').submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
});