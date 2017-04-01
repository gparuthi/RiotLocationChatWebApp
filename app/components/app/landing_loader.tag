<landingloader>

<div id="page">
  <div id="phrase_box">
  <svg width="100%" height="100%">
    <defs>
      <!--<style type="text/css">
        @font-face {
          font-family: "Proxima";
          src: url('');
        }
      </style>-->
      <mask id="mask" maskUnits="userSpaceOnUse" maskContentUnits="userSpaceOnUse">
        <linearGradient id="linearGradient" gradientUnits="objectBoundingBox" x2="0" y2="1">
          <stop stop-color="white" stop-opacity="0" offset="0%"/>
          <stop stop-color="white" stop-opacity="1" offset="30%"/>
          <stop stop-color="white" stop-opacity="1" offset="70%"/>
          <stop stop-color="white" stop-opacity="0" offset="100%"/>
        </linearGradient>
        <rect width="100%" height="100%" fill="url(#linearGradient)"/>
      </mask>
    </defs>
    <g width="100%" height="100%" style="mask: url(#mask);">
      <g id="phrases"></g>
    </g>
  </svg>
  </div>
  <div id="footer">
    <div id="logo"></div>Sophus
  </div>
</div>


<script>
	var self = this;
	var checkmarkIdPrefix = "loadingCheckSVG-";
	var checkmarkCircleIdPrefix = "loadingCheckCircleSVG-";
	var verticalSpacing = 50;

	this.on('mount', function() {
		var phrases = ["", "Creating custom profile", "Drawing mapview", "Fetching recent content", "Searching location", "Creating communities"];
		addPhrasesToDocument(phrases);
		var start_time = new Date().getTime();
		var upward_moving_group = document.getElementById("phrases");
		upward_moving_group.currentY = 0;
		var checks = phrases.map(function(_, i) {
		return {check: document.getElementById(checkmarkIdPrefix + i), circle: document.getElementById(checkmarkCircleIdPrefix + i)};
		});

		function animateLoading() {
			var now = new Date().getTime();
			upward_moving_group.setAttribute("transform", "translate(0 " + upward_moving_group.currentY + ")");
			upward_moving_group.currentY -= 1.35 * easeInOut(now);
			checks.forEach(function(check, i) {
			  var color_change_boundary = - i * verticalSpacing + verticalSpacing + 15;
			  if (upward_moving_group.currentY < color_change_boundary) {
			    var alpha = Math.max(Math.min(1 - (upward_moving_group.currentY - color_change_boundary + 15)/30, 1), 0);
			    check.circle.setAttribute("fill", "rgba(255, 255, 255, " + alpha + ")");
			    var check_color = [Math.round(255 * (1-alpha) + 120 * alpha), Math.round(255 * (1-alpha) + 154 * alpha)];
			    check.check.setAttribute("fill", "rgba(255, " + check_color[0] + "," + check_color[1] + ", 1)");
			  }
			})
			if (now - start_time < 30000 && upward_moving_group.currentY > -710) {
			  requestAnimationFrame(animateLoading);
			}
		}
		animateLoading();
	})

	function shuffleArray(array) {
	    for (var i = array.length - 1; i > 0; i--) {
	        var j = Math.floor(Math.random() * (i + 1));
	        var temp = array[i];
	        array[i] = array[j];
	        array[j] = temp;
	    }
	    return array;
	}

	function createSVG(tag, properties, opt_children) {
	  var newElement = document.createElementNS("http://www.w3.org/2000/svg", tag);
	  for(prop in properties) {
	    newElement.setAttribute(prop, properties[prop]);
	  }
	  if (opt_children) {
	    opt_children.forEach(function(child) {
	      newElement.appendChild(child);
	    })
	  }
	  return newElement;
	}

	function createPhraseSvg(phrase, yOffset) {
	  var text = createSVG("text", {
	    fill: "white",
	    x: 50,
	    y: yOffset,
	    "font-size": 18,
	    "font-family": "Arial"
	  });
	  text.appendChild(document.createTextNode(phrase + "..."));
	  return text;
	}
	function createCheckSvg(yOffset, index) {
	  var check = createSVG("polygon", {
	    points: "21.661,7.643 13.396,19.328 9.429,15.361 7.075,17.714 13.745,24.384 24.345,9.708 ",
	    fill: "rgba(255,255,255,1)",
	    id: checkmarkIdPrefix + index
	  });
	  var circle_outline = createSVG("path", {
	    d: "M16,0C7.163,0,0,7.163,0,16s7.163,16,16,16s16-7.163,16-16S24.837,0,16,0z M16,30C8.28,30,2,23.72,2,16C2,8.28,8.28,2,16,2 c7.72,0,14,6.28,14,14C30,23.72,23.72,30,16,30z",
	    fill: "white"
	  })
	  var circle = createSVG("circle", {
	    id: checkmarkCircleIdPrefix + index,
	    fill: "rgba(255,255,255,0)",
	    cx: 16,
	    cy: 16,
	    r: 15
	  })
	  var group = createSVG("g", {
	    transform: "translate(10 " + (yOffset - 20) + ") scale(.9)"
	  }, [circle, check, circle_outline]);
	  return group;
	}

	function addPhrasesToDocument(phrases) {
	  phrases.forEach(function(phrase, index) {
	    var yOffset = 30 + verticalSpacing * index;
	    document.getElementById("phrases").appendChild(createPhraseSvg(phrase, yOffset));
	    document.getElementById("phrases").appendChild(createCheckSvg(yOffset, index));
	  });
	}

	function easeInOut(t) {
	  var period = 200;
	  return (Math.sin(t / period + 100) + 1) /2;
	}
</script>

<style scoped>
#page {
  -webkit-box-align: center;
  -webkit-align-items: center;
      -ms-flex-align: center;
          align-items: center;
  background: -webkit-linear-gradient(bottom left, #1ca5e8 10%, #6fd9bb 65%, #5ebfca 125%);
  background: linear-gradient(to top right, #1ca5e8 10%, #6fd9bb 65%, #5ebfca 125%);
  bottom: 0;
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-pack: center;
  -webkit-justify-content: center;
      -ms-flex-pack: center;
          justify-content: center;
  left: 0;
  position: absolute;
  right: 0;
  top: 0;
  -webkit-transition: opacity 1s;
  transition: opacity 1s;
}

#phrase_box {
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
  -webkit-flex-flow: column;
      -ms-flex-flow: column;
          flex-flow: column;
  height: 150px;
  width: 260px;
}

#phrases {
  -webkit-animation: slide-phrases-upward 20s;
          animation: slide-phrases-upward 20s;
}

#footer {
  bottom: 30px;
  color: white;
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-pack: center;
  -webkit-justify-content: center;
      -ms-flex-pack: center;
          justify-content: center;
  left: 0;
  position: fixed;
  right: 0;
}

@-webkit-keyframes slide-phrases-upward {
  0% {
    -webkit-transform: translateY(0px);
            transform: translateY(0px);
  }
  5% {
    -webkit-transform: translateY(-50px);
            transform: translateY(-50px);
  }
  10% {
    -webkit-transform: translateY(-100px);
            transform: translateY(-100px);
  }
  15% {
    -webkit-transform: translateY(-150px);
            transform: translateY(-150px);
  }
  20% {
    -webkit-transform: translateY(-200px);
            transform: translateY(-200px);
  }
  25% {
    -webkit-transform: translateY(-250px);
            transform: translateY(-250px);
  }
  30% {
    -webkit-transform: translateY(-300px);
            transform: translateY(-300px);
  }
  35% {
    -webkit-transform: translateY(-350px);
            transform: translateY(-350px);
  }
  40% {
    -webkit-transform: translateY(-400px);
            transform: translateY(-400px);
  }
  45% {
    -webkit-transform: translateY(-450px);
            transform: translateY(-450px);
  }
  50% {
    -webkit-transform: translateY(-500px);
            transform: translateY(-500px);
  }
  55% {
    -webkit-transform: translateY(-550px);
            transform: translateY(-550px);
  }
  60% {
    -webkit-transform: translateY(-600px);
            transform: translateY(-600px);
  }
  65% {
    -webkit-transform: translateY(-650px);
            transform: translateY(-650px);
  }
  70% {
    -webkit-transform: translateY(-700px);
            transform: translateY(-700px);
  }
  75% {
    -webkit-transform: translateY(-750px);
            transform: translateY(-750px);
  }
  80% {
    -webkit-transform: translateY(-800px);
            transform: translateY(-800px);
  }
  85% {
    -webkit-transform: translateY(-850px);
            transform: translateY(-850px);
  }
  90% {
    -webkit-transform: translateY(-900px);
            transform: translateY(-900px);
  }
  95% {
    -webkit-transform: translateY(-950px);
            transform: translateY(-950px);
  }
  100% {
    -webkit-transform: translateY(-1000px);
            transform: translateY(-1000px);
  }
}

@keyframes slide-phrases-upward {
  0% {
    -webkit-transform: translateY(0px);
            transform: translateY(0px);
  }
  5% {
    -webkit-transform: translateY(-50px);
            transform: translateY(-50px);
  }
  10% {
    -webkit-transform: translateY(-100px);
            transform: translateY(-100px);
  }
  15% {
    -webkit-transform: translateY(-150px);
            transform: translateY(-150px);
  }
  20% {
    -webkit-transform: translateY(-200px);
            transform: translateY(-200px);
  }
  25% {
    -webkit-transform: translateY(-250px);
            transform: translateY(-250px);
  }
  30% {
    -webkit-transform: translateY(-300px);
            transform: translateY(-300px);
  }
  35% {
    -webkit-transform: translateY(-350px);
            transform: translateY(-350px);
  }
  40% {
    -webkit-transform: translateY(-400px);
            transform: translateY(-400px);
  }
  45% {
    -webkit-transform: translateY(-450px);
            transform: translateY(-450px);
  }
  50% {
    -webkit-transform: translateY(-500px);
            transform: translateY(-500px);
  }
  55% {
    -webkit-transform: translateY(-550px);
            transform: translateY(-550px);
  }
  60% {
    -webkit-transform: translateY(-600px);
            transform: translateY(-600px);
  }
  65% {
    -webkit-transform: translateY(-650px);
            transform: translateY(-650px);
  }
  70% {
    -webkit-transform: translateY(-700px);
            transform: translateY(-700px);
  }
  75% {
    -webkit-transform: translateY(-750px);
            transform: translateY(-750px);
  }
  80% {
    -webkit-transform: translateY(-800px);
            transform: translateY(-800px);
  }
  85% {
    -webkit-transform: translateY(-850px);
            transform: translateY(-850px);
  }
  90% {
    -webkit-transform: translateY(-900px);
            transform: translateY(-900px);
  }
  95% {
    -webkit-transform: translateY(-950px);
            transform: translateY(-950px);
  }
  100% {
    -webkit-transform: translateY(-1000px);
            transform: translateY(-1000px);
  }
}
#loadingCheckCircleSVG-0 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: -1.5s;
          animation-delay: -1.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-1 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: -0.5s;
          animation-delay: -0.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-2 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 0.5s;
          animation-delay: 0.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-3 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 1.5s;
          animation-delay: 1.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-4 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 2.5s;
          animation-delay: 2.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-5 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 3.5s;
          animation-delay: 3.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-6 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 4.5s;
          animation-delay: 4.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-7 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 5.5s;
          animation-delay: 5.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-8 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 6.5s;
          animation-delay: 6.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-9 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 7.5s;
          animation-delay: 7.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-10 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 8.5s;
          animation-delay: 8.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-11 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 9.5s;
          animation-delay: 9.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-12 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 10.5s;
          animation-delay: 10.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-13 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 11.5s;
          animation-delay: 11.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-14 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 12.5s;
          animation-delay: 12.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-15 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 13.5s;
          animation-delay: 13.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-16 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 14.5s;
          animation-delay: 14.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-17 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 15.5s;
          animation-delay: 15.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-18 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 16.5s;
          animation-delay: 16.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-19 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 17.5s;
          animation-delay: 17.5s;
  fill: white;
  opacity: 0;
}

#loadingCheckCircleSVG-20 {
  -webkit-animation: fill-to-white 5000ms;
          animation: fill-to-white 5000ms;
  -webkit-animation-delay: 18.5s;
          animation-delay: 18.5s;
  fill: white;
  opacity: 0;
}

@-webkit-keyframes fill-to-white {
  0% {
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  100% {
    opacity: 1;
  }
}

@keyframes fill-to-white {
  0% {
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  100% {
    opacity: 1;
  }
}
#loadingCheckSVG-0 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: -1.5s;
          animation-delay: -1.5s;
}

#loadingCheckSVG-1 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: -0.5s;
          animation-delay: -0.5s;
}

#loadingCheckSVG-2 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 0.5s;
          animation-delay: 0.5s;
}

#loadingCheckSVG-3 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 1.5s;
          animation-delay: 1.5s;
}

#loadingCheckSVG-4 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 2.5s;
          animation-delay: 2.5s;
}

#loadingCheckSVG-5 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 3.5s;
          animation-delay: 3.5s;
}

#loadingCheckSVG-6 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 4.5s;
          animation-delay: 4.5s;
}

#loadingCheckSVG-7 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 5.5s;
          animation-delay: 5.5s;
}

#loadingCheckSVG-8 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 6.5s;
          animation-delay: 6.5s;
}

#loadingCheckSVG-9 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 7.5s;
          animation-delay: 7.5s;
}

#loadingCheckSVG-10 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 8.5s;
          animation-delay: 8.5s;
}

#loadingCheckSVG-11 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 9.5s;
          animation-delay: 9.5s;
}

#loadingCheckSVG-12 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 10.5s;
          animation-delay: 10.5s;
}

#loadingCheckSVG-13 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 11.5s;
          animation-delay: 11.5s;
}

#loadingCheckSVG-14 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 12.5s;
          animation-delay: 12.5s;
}

#loadingCheckSVG-15 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 13.5s;
          animation-delay: 13.5s;
}

#loadingCheckSVG-16 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 14.5s;
          animation-delay: 14.5s;
}

#loadingCheckSVG-17 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 15.5s;
          animation-delay: 15.5s;
}

#loadingCheckSVG-18 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 16.5s;
          animation-delay: 16.5s;
}

#loadingCheckSVG-19 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 17.5s;
          animation-delay: 17.5s;
}

#loadingCheckSVG-20 {
  -webkit-animation: fill-to-coral 5000ms;
          animation: fill-to-coral 5000ms;
  -webkit-animation-delay: 18.5s;
          animation-delay: 18.5s;
}

@-webkit-keyframes fill-to-coral {
  0% {
    fill: white;
  }
  10% {
    fill: #5FD5B3;
  }
  100% {
    fill: #5FD5B3;
  }
}

@keyframes fill-to-coral {
  0% {
    fill: white;
  }
  10% {
    fill: #5FD5B3;
  }
  100% {
    fill: #5FD5B3;
  }
}

</style>
</landingloader>