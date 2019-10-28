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
	lastLabel:null,
	
	init:function(mc){
		this.mc=mc;
		mc._SuperMC=this;
		mc.addEventListener(Event.ENTER_FRAME,this.onEnterFrame(this));
	},
	
	onEnterFrame:function(scope){
		var t = scope;
		return function(e){
			if(t.loopLabel){
				if(!t.lastLabel&&t.mc.currentLabel){
					t.lastLabel=t.mc.currentLabel;
				}else if(t.lastLabel&&t.mc.currentLabel!=t.lastLabel){
					t.mc.gotoAndPlay(t.lastLabel);
				}
			}
			
		}
	}
	
}}

function Block(){return{

	mc:null,
	
	init:function(x,y){

		this.mc=new BlockMC();
			
		SuperMC().init(this.mc);
		
		this.mc._Block=this;
		this.mc.gotoAndPlay(Math.floor(Math.random()*this.mc.totalFrames));
		this.mc.x=x;
		this.mc.y=y;
		addChild(this.mc);
		this.mc.addEventListener(MouseEvent.CLICK,this.onClick(this));
		
	},
	
	onClick:function(scope){
		var t = scope;
		return function(e){
			t.remove();
		}
	},
	
	remove:function(){
		
		if(!this.mc.parent){
			return;
		}
		
		this.mc.parent.removeChild(this.mc);
		
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

	}
	
}}