$('#myModal .modal-body').html("User created successfully!")
$('#newuserform').submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
});