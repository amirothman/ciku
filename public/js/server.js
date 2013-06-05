$( document ).ready(function() {

  $( ".atas" ).click(function() {
  	var path;
  	path = this.getAttribute("path")
  
   		$.ajax({
			dataType: 'json',
			url: path,
			success: function(set){
			$("#right").replaceWith('<div id="right" class="span6"><h3>'+set.site[0]+'</h3><p>'+set.site[1]+'</p></div>');
			
			//$('<div class="fb-like" data-href='+'/idiom/'+id+'data-send="true" data-width="450" data-show-faces="true"></div>').appendTo("#resultsbox");
			}
				});

  });

    $( ".justifymid" ).click(function() {
  	var path;
  	path = this.getAttribute("path")
  
   		$.ajax({
			dataType: 'json',
			url: path,
			success: function(set){
			$("#right").replaceWith('<div id="right" class="span6"><h3>'+set.blogpost[0]+'</h3><p>'+set.blogpost[1]+'</p></div>');
			
			//$('<div class="fb-like" data-href='+'/idiom/'+id+'data-send="true" data-width="450" data-show-faces="true"></div>').appendTo("#resultsbox");
			}
				});

  });

});