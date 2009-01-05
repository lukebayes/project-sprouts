package {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.utils.setTimeout;
    import flash.errors.IllegalOperationError;
    
    public class SomeProject extends Sprite {
        
        public function SomeProject() {
            trace("SomeProject instantiated");
            setTimeout(triggerException, 1);
        }
        
        private function triggerException():void {
            var num:Number = 2;
            var str:String = 'hello';
            var obj:Object = {
                name: 'luke'
            };
            
            throw new IllegalOperationError('Custom Error');
            //addChild(DisplayObject({})); // Throw an exception here:
        }
    }
}
