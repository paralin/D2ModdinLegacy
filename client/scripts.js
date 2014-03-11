function _topNav(){
	window.topNavSmall = false;
	function topMain() {
		var _scrollTop 	= jQuery(document).scrollTop();

		if(_scrollTop > 0) {
			jQuery('header#topNav div.nav-main-collapse').addClass('topFix');
			jQuery('#topNav').stop().animate({ 'height':'60px'},400);
			jQuery('header#topNav div.nav-main-collapse').stop().animate({ 'margin-top':'0'},400);
			jQuery('header#topNav button').stop().animate({ 'margin-top':'-6px'},100);
			jQuery('header#topNav a.logo').stop().animate({ 'line-height':'0', 'margin-top':'-7px'},400);
			jQuery('#header_shadow').stop().animate({ 'top':'30px'},400);/* just a little visible */
			window.topNavSmall = true;
		} 

		if(window.topNavSmall === true && _scrollTop < 3) {
			jQuery('header#topNav div.nav-main-collapse').removeClass('topFix');
			jQuery('#topNav').stop().animate({ 'height':'92px'},400);
			jQuery('header#topNav div.nav-main-collapse').stop().animate({ 'margin-top':'16px'},400);
			jQuery('header#topNav button').stop().animate({ 'margin-top':'8px'},100);
			jQuery('header#topNav a.logo').stop().animate({ 'line-height':'50px', 'margin-top':'0'},400);
			jQuery('#header_shadow').stop().animate({ 'top':'92px'},400);
			window.topNavSmall = false;
		}

		if(jQuery('#topHead').length > 0) {
			if(_scrollTop > 0) {
				jQuery('#topHead').addClass('fixed');
			} else {
				jQuery('#topHead').removeClass('fixed');
			}
		}
	}
}
