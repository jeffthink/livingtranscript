$(document).ready(function(){
  setWorkspaceHeight();
  $(window).resize(function() {
    setWorkspaceHeight();
  });
  $("#workspace-header").live("click", function(e) {
    e.stopImmediatePropagation();
    e.preventDefault();
    if($("#workspace").height() > 200) {
      $("#workspace").animate({
        height: '35px'
      }, 550, function() {
        // Animation complete.
      });
    } else {
     $("#workspace").animate({
        height: '355px'
      }, 550, function() {
        // Animation complete.
      })
    }
  });

  $(".default-text").focus(clearDefaultText);

  var quickAddOpts = {
    dataType:  'html',      // 'xml', 'script', or 'json' (expected server response type)
    clearForm: true,        // clear all form fields after successful submit
    resetForm: true,        // reset the form after successful submit
    success: function(responseText, statusText, xhr, $form){
      $(".loading-spinner").hide();

      var cls = "success";
      var message = "suggestion sent";
      if(!responseText || parseInt(responseText) < 1){
        cls = "error";
        message = "suggestion not sent (email address not in our system)";
      }

      var h = '<div class="alert-message ' + cls + '" data-alert="alert"><a class="close" href="#">×</a><p>'+message+'</p></div>';
      $("#entry-suggest-message").html(h);
      $("#suggest-friend-message").show();
    },
    beforeSubmit: function(arr, $form, options) {
      $(".loading-spinner").show();
    }
  };
  $("#new-entry-quick-add").ajaxForm(quickAddOpts);

  setupNewEntryForm();
  setupRecommendationForm();
  setupEntryEvents();
  setupWorkspaceTagCloud();
  setupAccordion();
  setupRecommendationButtons();
  setupHashchange();

  if($("#admin-tags-cloud").length > 0) {
    setupAdminTagCloud();
  }

  if($("#admin-skill-filter-tag-cloud").length > 0){
    setupAdminSkillFilterTagCloud();
  }
});

setupNewEntryForm = function(){
  var options = {
    dataType:  'html',      // 'xml', 'script', or 'json' (expected server response type)
    clearForm: true,        // clear all form fields after successful submit
    resetForm: true,        // reset the form after successful submit
    beforeSubmit: function(formData, jqForm){
      if(!jqForm[0]['entry-title'].value){
        $(jqForm[0]['entry-title']).animate({'backgroundColor': '#FF0000'}, 1000)
          .animate({'backgroundColor': '#FFFFFF'}, 1000);
        return false;
      }
    },
    success: function(responseText, statusText, xhr, $form){
      $("#existing-entries .no-entries-message").remove();
      $("#new_entry_tags_tagsinput .tag").remove();
      var entry = $(responseText);
      entry.css({
        display: 'none'
      });
      $("#existing-entries").prepend(entry);
      entry.slideDown(750, function(){
        entry.animate({'backgroundColor': '#EEDC94'}, 500)
          .animate({'backgroundColor': '#FFFFFF'}, 500);
      });

      $("#workspace").animate({
        height: '35px'
      }, 500, function() {
        // Animation complete.
      });
    }
  };
  $("#new-entry").ajaxForm(options);
};

setWorkspaceHeight = function(){
  $("#work-page-container").css("height", $(document).height() - 35);
  $("body").css("height", $(document).height() - 35);
};

clearDefaultText = function(e) {
  e.preventDefault();
  e.stopImmediatePropagation();
  $(e.target).val("");
  $(e.target).removeClass("default-text");
  $(e.target).unbind("focus");
};

setupEntryEvents = function(){
  $("a.entry-delete").live("click", function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    if (confirm("Are you sure you want to delete this entry?")) {
      var target = $(e.target);
      var entryId = target.data("entryId");
      $.ajax("/entries/"+entryId, {
        type: "DELETE",
        success: function(data, textStatus, jqXHR) {
          if (textStatus == "success") {
            target.parent().parent().parent().fadeOut(500, function(){
              $(this).remove();
              if ($("#existing-entries").children().length == 0) {
                $("#existing-entries").append("<div class='no-entries-message'>You haven't created any entries yet!</div>");
              }
            });
          }
        }
      });
    }
  });
  $("a.entry-edit").live("click", function(e) {
    var target = $(e.target),
            entryId = target.data("entryId");
    e.preventDefault();
    e.stopImmediatePropagation();

    $("#workspace").load("/entries/"+entryId+"/edit",function(responseText, textStatus, xhr) {
      setupAccordion();
      setupWorkspaceTagCloud();

      var options = {
        type: "put",
        dataType:  'html',      // 'xml', 'script', or 'json' (expected server response type)
        clearForm: true,        // clear all form fields after successful submit
        resetForm: true,        // reset the form after successful submit
        beforeSubmit: function(formData, jqForm){
          if(!jqForm[0]['entry-title'].value){
            $(jqForm[0]['entry-title']).animate({'backgroundColor': '#FF0000'}, 1000)
              .animate({'backgroundColor': '#FFFFFF'}, 1000);
            return false;
          }
        },
        success: function(responseText, statusText, xhr, $form){
          var entry = $(".entry[data-entry-id='"+entryId+"']");

          var newEntry = $(responseText);
          entry.replaceWith(newEntry);
          newEntry.animate({'backgroundColor': '#EEDC94'}, 1000)
            .animate({'backgroundColor': '#FFFFFF'}, 1000);

          $("#workspace").animate({
            height: '35px'
          }, 500, function() {
            $("#workspace").load("/entries/new", function(){
              setupWorkspaceTagCloud();
              setupAccordion();
              setupNewEntryForm();
            });
          });
        }
      };
      $("#edit-entry").ajaxForm(options);

      if($("#workspace").height() < 200) {
       $("#workspace").animate({
          height: '355px'
        }, 500, function() {
          // Animation complete.
        })
      }
    });
  });

  $("#cancel-new-entry").live("click", function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    $("#workspace").animate({
        height: '35px'
      }, 500, function() {
      });
  });

  $("#cancel-edit-entry").live("click", function(e){
    e.preventDefault();
    e.stopImmediatePropagation();
    $("#workspace").animate({
        height: '35px'
      }, 500, function() {
        $("#workspace").load("/entries/new", function(){
          setupWorkspaceTagCloud();
          setupAccordion();
        });
      });
  });
};

setupWorkspaceTagCloud = function() {
  if ($("#workspace-tag-cloud").length > 0) {
    $.get("/tags", function(data, textStatus, jqXHR){
      jQuery.each(data, function(i, val){
        $('#workspace-tag-cloud').append("<li value='" + val.value + "'><a href='" + val.url + "'>" + val.text + "</a></li>");
      });

      $('#workspace-tag-cloud').tagcloud({type:"list",sizemin:10});
    });

    $("#workspace-tag-cloud").click(function(e){
      e.preventDefault();
      e.stopImmediatePropagation();
      var target = $(e.target);
      if (target.is("a")) {
        $('.tags-input').addTag(target.html());
      }
    });
  }
  $(".tags-input").tagsInput({
    'unique': true,
    'defaultText':'add a tag',
    'height':'28px',
    'width':'375px'
  });
};

setupAdminTagCloud = function() {
  $.get("/tags?limit=20&recent=1", function(data, textStatus, jqXHR){
    jQuery.each(data, function(i, val){
      $('#admin-tags-cloud').append("<li value='" + val.value + "'><a href='" + val.url + "'>" + val.text + "</a></li>");
    });

    $('#admin-tags-cloud').tagcloud({type:"list",sizemin:10, height:100, width:150});
  });
};

setupAdminSkillFilterTagCloud = function() {
  $.get("/tags", function(data, textStatus, jqXHR){
    var allTags = [];
    jQuery.each(data, function(i, val){
      $('#admin-skill-filter-tag-cloud').append("<li value='" + val.value + "'><a id='skill-tag-" + val.id + "' href='" + val.url + "'>" + val.text + "</a></li>");
      allTags.push(val.id);
    });

    $('#skill_all_tags').val(allTags.join(","));

    $('#admin-skill-filter-tag-cloud').tagcloud({type:"list",sizemin:10});

    $('#admin-skill-filter-tag-cloud a').live("click", function(){
      var currTags = $('#skill_selected_tags').val().split(',');
      if(currTags == ""){
        currTags = [];
      }

      var t = this.id.split("-")[2];
      var index = jQuery.inArray(t, currTags);
      if(index >= 0){ //not selected yet
        currTags.splice(index, 1);

        $(this).css("color", $(this).css("backgroundColor"));
        $(this).css("backgroundColor", "#FFFFFF");
      } else{
        currTags.push(t);

        $(this).css("backgroundColor", $(this).css("color"));
        $(this).css("color", "#FFFFFF");
      }

      var currTags = $('#skill_selected_tags').val(currTags.join(','));

      loadSkillFilterResults();
    });

    $('input:radio[name=tag_operator]').change(function(){
      loadSkillFilterResults();
    });

    $('#skill-date-range-start').datepicker();
    $('#skill-date-range-end').datepicker();

    $('#skill-date-range-start').change(function(){
      loadSkillFilterResults();
    });

    $('#skill-date-range-end').change(function(){
      loadSkillFilterResults();
    });

    loadSkillFilterResults();
  });
};

loadSkillFilterResults = function() {
  var url = 'entries';

  var allTags = $('#skill_all_tags').val();
  var currTags = $('#skill_selected_tags').val();

  var tagOperator = $('input:radio[name=tag_operator]:checked').val();

  url += "?selected_tags=" + currTags + "&all_tags=" + allTags + "&tag_operator=" + tagOperator;

  var startDate = $('#skill-date-range-start').val();
  var endDate = $('#skill-date-range-end').val();
  if(startDate && endDate){
    url += "&start_date=" + startDate + "&end_date=" + endDate;
  }

  $.get(url, function(responseText, textStatus, jqXHR){
    $('#skill-filter-results').html(responseText);
  });
}

setupUserTagCloud = function() {
  $.get("/tags?by_user=1", function(data, textStatus, jqXHR){
    jQuery.each(data, function(i, val){
      $('#user-tags-cloud').append("<li value='" + val.value + "'><a href='" + val.url + "'>" + val.text + "</a></li>");
    });

    $('#user-tags-cloud').tagcloud({type:"sphere",sizemin:14,sizemax:26,power:.3, height:150});
  });
};

setupAccordion = function() {
  $("#accordion").accordion();
};

setupRecommendationForm = function() {
  var options = {
    dataType:  'json',      // 'xml', 'script', or 'json' (expected server response type)
    clearForm: true,        // clear all form fields after successful submit
    resetForm: true,        // reset the form after successful submit
    success: function(responseText, statusText, xhr, $form){
      window.location="/";
    }
  };
  $("#edit-recommendation").ajaxForm(options);
};

setupRecommendationButtons = function() {
  $("#approve-recommendation").live("click", function() {
    $("#recommendation_status").val("CONFIRMED");
    var options = {
      dataType:  'json',      // 'xml', 'script', or 'json' (expected server response type)
      success: function(responseText, statusText, xhr, $form){
        window.location="/";
      }
    };

    $("form.edit-recommendation-status").ajaxSubmit(options);
  });

  $("#decline-recommendation").live("click", function() {
    $("#recommendation_status").val("DENIED");
    var options = {
      dataType:  'json',      // 'xml', 'script', or 'json' (expected server response type)
      success: function(responseText, statusText, xhr, $form){
        window.location="/";
      }
    };
    $("form.edit-recommendation-status").ajaxSubmit(options);
  });
};

setupHashchange = function() {

  // Bind an event to window.onhashchange that, when the history state changes,
  // gets the url from the hash and displays either our cached content or fetches
  // new content to be displayed.
  $(window).bind( 'hashchange', function(e) {

    // Get the hash (fragment) as a string, with any leading # removed. Note that
    // in jQuery 1.4, you should use e.fragment instead of $.param.fragment().
    var url = $.param.fragment();
    // Remove .active class from any previously "current" link(s).
    if (url != "") {
      $("ul.tabs li.active").removeClass("active");

      var tabHeight= $(".tab-content").height(),
          tabWidth = $(".tab-content").width(),
          tabPosition= $(".tab-content").position();
      $(".loading-overlay").css({height: tabHeight,
        width: tabWidth, top: tabPosition.top, left: tabPosition.left});
      $(".loading-overlay").show();
      // Add .bbq-current class to "current" nav link(s), only if url isn't empty.
      //    url && $( 'a[href="#' + url + '"]' ).parent.addClass( 'active' );
      $('a[href="#' + url + '"]' ).parent().addClass('active');
      $(".tab-content").load("/"+url, function(){
        $(".loading-overlay").hide();

        if($("#user-tags-cloud").length > 0) {
          setupUserTagCloud();
        }
      });
    }
  });

  $(window).trigger( 'hashchange' );
};

$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});
