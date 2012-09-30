package fr.hyperfiction.hypertouch;

import fr.hyperfiction.hypertouch.gestures.AGesture;
import fr.hyperfiction.hypertouch.gestures.GestureTap;

#if android
import haxe.Timer;
import nme.events.Event;
import nme.JNI;
#end

#if cpp
import cpp.Lib;
import nme.Lib;
#end

/**
 * ...
 * @author shoe[box]
 */

class HyperTouch{

	public static inline var GESTURE_TAP_1 : Int = 0;
	public static inline var GESTURE_TAP_2 : Int = 1;
	public static inline var GESTURE_TWO_FINGERS_TAP : Int = 2;

	private var _hGestures : IntHash<AGesture>;

	#if android
	private var _f_disable    : Dynamic;
	private var _f_enable     : Dynamic;
	private var _java_instance: Dynamic;
	private var _timer        : Timer;
	private static inline var ANDROID_CLASS : String = 'fr.hyperfiction.hypertouch.HyperTouch';
	#end

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		private function new() {
			_init( );
		}
	
	// -------o public
				
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public function add( gesture : GestureTypes ) : Void {
			
			switch( gesture ){

				case TAP( fingers_count , taps_count ):
					_add_tap_with( fingers_count , taps_count );

			}
						
		}

	// -------o protected
		
		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private function _init( ) : Void{
			_hGestures = new IntHash<AGesture>( );

			#if android
			nme.Lib.current.stage.addEventListener( Event.DEACTIVATE , _onDeactivate , false );
			#end
		}

		#if android

		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private function _onDeactivate( _ ) : Void{
			trace('_onDeactivate');
			
			//
				if( _timer != null )
					_timer.stop( );

			//Instance of the HyperTouch java class
				if( _java_instance == null ){
					var f = JNI.createStaticMethod( ANDROID_CLASS , 'getInstance' , '()Lfr/hyperfiction/hypertouch/HyperTouch;');
					_java_instance = f( );
				}

			//Calling the disable function
				if( _f_disable == null )
					_f_disable = JNI.createMemberMethod( ANDROID_CLASS , 'disable' , '()V' );
					_f_disable( _java_instance );

				nme.Lib.current.stage.addEventListener( Event.ACTIVATE , _onActivate , false );
		}

		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private function _onActivate( _ ) : Void{
			trace('_onActivate');
			if( _f_enable == null )
				_f_enable = JNI.createMemberMethod( ANDROID_CLASS , 'enable' , '()V' );
			
			//Waiting for the GLSurfaceView reinitialization
				_timer = Timer.delay( function( ){
											_f_enable( _java_instance );
											} , 10 );

		}

		#end

		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private function _add_tap_with( fingers_count : Int , taps_count : Int = 1 ) : Void{

			var value : Int = -1;
			switch( taps_count ){

				case 1:
					if( fingers_count == 1 )
						value = GESTURE_TAP_1;
					else if( fingers_count == 2 )
						value = GESTURE_TWO_FINGERS_TAP;


				case 2:
					value = GESTURE_TAP_2;

				default:
					trace('todo');

			}

			if( !_hGestures.exists( value ) ){

				var g = new GestureTap( fingers_count , taps_count );
					g.enabled = true;
				_hGestures.set( value , g );

			}


		}

	// -------o misc
		
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		static public function add_listener_for( gesture : GestureTypes ) : Void {
			getInstance( ).add( gesture );
		}

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		static public function getInstance( ) : HyperTouch {
			
			if( __instance == null )
				__instance = new HyperTouch( );

			return __instance;

		}	

		private static var __instance : HyperTouch = null;
}

enum GestureTypes{

	TAP( fingers_count : Int , ?taps_count : Int );

}