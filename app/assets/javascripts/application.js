// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require highcharts
//= require highcharts-more
//= require exporting
//= require jqcloud-1.0.2.min
//= require footable
//= require footablesortable
//= require footablefilter
//= require_tree .

$(function () {
jQuery.ajaxSetup({
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

$(document).ready(function (){
    $('#new_review').submit(function (){
        $.post($(this).attr('action'), $(this).serialize(), null, "script");
        return false;
    });
    $('#newuserform').submit(function() {
        $.post(this.action, $(this).serialize(), null, "script");
        return false;
    });
    $('#newreviewform').submit(function() {
        $.post(this.action, $(this).serialize(), null, "script");
        return false;
    });
});
});

function new_user(){

    var obj = this;
    obj.el_body = $("#myModal .modal-body");
    obj.button_id = '#submit';
    obj.form_id = '#newuserform';
    obj.el_form = null;

    obj.init = function() {

        obj.el_form = $(obj.form_id);

        $(obj.button_id).click(function(){
            obj.el_form.submit();
        });

        obj.setup_form();

    };

    obj.setup_form = function() {

        obj.el_form.submit(function(e){
            e.preventDefault();
            $.post( obj.el_form.action, obj.el_form.serialize(), function( data ) {
                obj.el_body.html(data);
                obj.el_form = obj.el_body.find(obj.form_id);
                obj.setup_form();
            });
        });

    };
    obj.init();
}