import org.casaframework.event.DispatchableInterface;
/**
 * @author darren
 */
interface com.modestmaps.io.IRequest 
extends DispatchableInterface
{
	public function send() : Void;
	public function execute() : Void;
	public function isBlocking() : Boolean;
}
