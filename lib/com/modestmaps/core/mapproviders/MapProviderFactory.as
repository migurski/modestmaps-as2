/**
 * Factory for generating instances of MapProviders.
 * 
 * @author darren
 */
 
import com.modestmaps.core.mapproviders.*; 
 
class com.modestmaps.core.mapproviders.MapProviderFactory 
{
	private static var __instance : MapProviderFactory;
	
	/* 
	 * Singleton, use getInstance().
	 */
	private function MapProviderFactory()
	{
	}
	
	public function toString() : String
	{
		return "MapProviderFactory[]";	
	}
	
	/*
	 * Returns an instance of the MapProviderFactory.
	 * 
	 * @return The MapProviderFactory singleton.
	 */
	public static function getInstance() : MapProviderFactory
	{
		if ( __instance == undefined ) __instance = new MapProviderFactory();
		return __instance;
	}
	
	/*
	 * Instantiates the proper MapProvider.
	 * 
	 * @param mapProviderType A constant provided by the MapProviders enumeration.
	 * @return A class which implements IMapProvider.
	 */
	public function getMapProvider ( mapProviderType : Number ) : IMapProvider
	{
		switch ( mapProviderType )
		{
			case MapProviders.VANILLA :
				return new VanillaMapProvider();

			case MapProviders.MICROSOFT_ROAD :
				return new MicrosoftRoadMapProvider();

			case MapProviders.MICROSOFT_AERIAL :
				return new MicrosoftAerialMapProvider();

			case MapProviders.MICROSOFT_HYBRID :
				return new MicrosoftHybridMapProvider();
				
			case MapProviders.MICROSOFT_DELAYED :
				return new MicrosoftDelayedAerialMapProvider();
				
			default :
				trace ( this.toString() + ": invalid MapProvider requested: " + mapProviderType);
				return null;
		}
	}
}