//Ubiquitous dollar function
var $ = function( el ){
	return document.getElementById( el );
};
var NewsLoader = function( el, title, url ){
	//Private Members
	var _setupList = function( ){
		_el.innerHTML = "<p><strong>"+_title+"</strong></p><ul id='news_list'></ul>";
	};
	var _addItem = function( list, entry ){
		list.innerHTML += "<li><a href='"+entry.link+"'>"+entry.title+"</a><br/>"+entry.contentSnippet+"</li>";
	};
	var _showError = function(){
		_el.innerHTML = "<h3>Sorry, could not load news feed</h3>";
	};
	var _addFeed = function( result ){
		try{	
			if( result.error || !result.feed.entries.length ) 
				throw new Error("Service not available");
			
			_setupList( );
			var list = $("news_list");
			for(var x=0; x<result.feed.entries.length; x++){
				_addItem( list, result.feed.entries[x] );
			}
		}
		catch(e)
		{
			_showError();
		}
	};
	//Constructor
	try{
		var _url = url;
		var _el = $(el);
		var _title = title;
		var _feed = new google.feeds.Feed( _url );
		_feed.load( _addFeed );
	}catch(e){
		_showError();
	}
};
google.load("feeds", "1");
google.setOnLoadCallback(function(){
	new NewsLoader( 'news', 'Topics from the Sprouts Group', "http://groups.google.com/group/projectsprouts/feed/rss_v2_0_topics.xml");
	new NewsLoader( 'talk', 'Recent Article\'s about Sprouts', "http://blogsearch.google.com/blogsearch_feeds?hl=en&safe=off&um=1&tab=wb&q=site:http://www.asserttrue.com+sprouts&ie=utf-8&num=10&output=atom");
});