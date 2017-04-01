OptsMixin = {
    track: function(arg, arg2) {
    	arg = arg || 'default';
    	arg2 = arg2 || '';
    	var tagName = this.root.tagName;
    	fbq('trackCustom', tagName , {"action": arg});
    	ga('send', {
		  "hitType": 'event',
		  "eventCategory": tagName,
		  "eventAction": arg,
		  "eventLabel": arg2,
		});
  }
}