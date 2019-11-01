import flash.events.MouseEvent;
import flash.display.MovieClip;
import flash.events.Event;

var main=Main();
main.init();

function Main(){return{
	
	boardWidth:16,
	boardHeight:24,
	blockWidth:40,
	blockHeight:40,
	blocks:[],
	
	init:function(){
		var i,j,block;
		for(i=0;i<this.boardWidth;i++){
			for(j=0;j<this.boardHeight;j++){
				block=Block();
				block.init(i*this.blockWidth,j*this.blockHeight);
				this.blocks.push(block);
			}
		}
	},
	
	getBlockAtXY:function(x,y){
		var i=0;
		var len=this.blocks.length;
		for(i=0;i<len;i++){
			if(this.blocks[i].mc.hitTestPoint(x,y)){
				return this.blocks[i].mc;
			}
		}
	}
	
}}

function SuperMC(){return{
	
	mc:null,
	
	loopLabel:true,
	lastLabelFrame:{},
	
	moveToData:null,
	playOnce:false,
	
	endLabelFrameFunc:null,
	
	z:0,
	
	init:function(mc){
		this.mc=mc;
		swapChildren(mc,getChildAt(0));
		mc._SuperMC=this;
		mc.addEventListener(Event.ENTER_FRAME,this.onEnterFrame(this));

		this.setupLabels();

		return this;
	},
	
	setupLabels:function(){
		var i;
		var len=this.mc.currentLabels.length;
		var lastLabel;
		for (i=0;i<len;i++) {
			if(lastLabel){
				this.lastLabelFrame[this.mc.currentLabels[i].frame-1]=lastLabel;
			}
			lastLabel=this.mc.currentLabels[i].name;
		}
		if(len){
			this.lastLabelFrame[this.mc.totalFrames-1]=lastLabel;
		}
	},
	
	setEndLabelFrameFunc:function(func){
		this.endLabelFrameFunc=func;
	},
	
	gotoAndPlay:function(label){
		this.mc.gotoAndPlay(label);
	},
	
	onEnterFrame:function(scope){
		var t = scope;
		return function(e){
			if(!t.mc.parent){
				return;
			}
			if(t.loopLabel){
				if(t.lastLabelFrame[t.mc.currentFrame]){
					t.mc.gotoAndPlay(t.lastLabelFrame[t.mc.currentFrame]);
					if(t.endLabelFrameFunc){
						t.endLabelFrameFunc();
						t.endLabelFrameFunc=null;
					}
				}
			}
			if(t.moveToData){
				var mv=t.moveToData;
				var pct=(getTimer()-mv.start)/(mv.end-mv.start);
				var x=mv.startX+((mv.endX-mv.startX)*pct);
				var y=mv.startY+((mv.endY-mv.startY)*pct);
				if(pct>=1){
					x=mv.endX;
					y=mv.endY;
					t.moveToData=null;
				}
				t.mc.x=x;
				t.mc.y=y;
			}
			if(t.z>0){
				var nextMC;
				while(true){
					if(getChildIndex(t.mc)+1==numChildren){
						break;
					}
					nextMC=getChildAt(getChildIndex(t.mc)+1);
					if(!nextMC){
						break;
					}else if(nextMC._SuperMC){
						if(nextMC._SuperMC.z<t.z){
							swapChildren(nextMC,t.mc);
						}else{
							break;
						}
					}else{
						nextMC.swapChildren(nextMC,t.mc);
					}
				}
			}
			if(t.playOnce&&t.mc.currentFrame==t.mc.totalFrames){
				t.destroy();
			}
		}
	},
	
	moveTo:function(ms,endX,endY){
		this.moveToData={startX:this.mc.x,startY:this.mc.y,endX:endX,endY:endY,start:getTimer(),end:getTimer()+ms};
	},
	
	destroy:function(){
		this.mc.parent?this.mc.parent.removeChild(this.mc):null;
	}
	
}}

function Block(){return{

	mc:null,
	
	init:function(x,y){

		this.mc=new BlockMC();

		this.mc._Block=this;
		this.mc.gotoAndPlay(Math.floor(Math.random()*this.mc.totalFrames));
		this.mc.x=x;
		this.mc.y=y;
		addChild(this.mc);
		
		SuperMC().init(this.mc);
		
		var t=this;
		this.mc.addEventListener(MouseEvent.CLICK,function(e){t.remove();});
		
	},
	
	remove:function(){
		
		if(!this.mc.parent){
			return;
		}
		
		this.destroy();
		
		var x=this.mc.x+2;
		var y=this.mc.y+2;
		
		var isMatch=function(adjacent,t){
			if(adjacent&&adjacent.parent&&adjacent.currentLabel==t.mc.currentLabel){
				adjacent._Block.remove();
			}
		}

		isMatch(main.getBlockAtXY(x-main.blockWidth,y),this);
		isMatch(main.getBlockAtXY(x+main.blockWidth,y),this);
		isMatch(main.getBlockAtXY(x,y-main.blockHeight),this);
		isMatch(main.getBlockAtXY(x,y+main.blockHeight),this);

	},

	destroy:function(){
		this.mc.parent?this.mc.parent.removeChild(this.mc):null;
	}
	
}}