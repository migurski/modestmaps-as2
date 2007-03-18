/**
 * Factory for generating instances of MapProviders.
 * 
 * @author darren
 */
 
import com.modestmaps.mapproviders.BlueMarbleMapProvider;
import com.modestmaps.mapproviders.google.GoogleAerialMapProvider;
import com.modestmaps.mapproviders.google.GoogleHybridMapProvider;
import com.modestmaps.mapproviders.google.GoogleRoadMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.MapProviders;
import com.modestmaps.mapproviders.microsoft.MicrosoftAerialMapProvider;
import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;
import com.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
import com.modestmaps.mapproviders.OpenStreetMapProvider;
import com.modestmaps.mapproviders.VanillaMapProvider;
import com.modestmaps.mapproviders.yahoo.YahooAerialMapProvider;
import com.modestmaps.mapproviders.yahoo.YahooHybridMapProvider;
import com.modestmaps.mapproviders.yahoo.YahooRoadMapProvider;

class com.modestmaps.mapproviders.MapProviderFactory 
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

			case MapProviders.BLUE_MARBLE :
				return new BlueMarbleMapProvider();

			case MapProviders.OPEN_STREET_MAP :
				return new OpenStreetMapProvider();

			case MapProviders.MICROSOFT_ROAD :
				return new MicrosoftRoadMapProvider();

			case MapProviders.MICROSOFT_AERIAL :
				return new MicrosoftAerialMapProvider();

			case MapProviders.MICROSOFT_HYBRID :
				return new MicrosoftHybridMapProvider();
				
			case MapProviders.GOOGLE_ROAD :
				return new GoogleRoadMapProvider();

			case MapProviders.GOOGLE_AERIAL :
				return new GoogleAerialMapProvider();

			case MapProviders.GOOGLE_HYBRID :
				return new GoogleHybridMapProvider();

			case MapProviders.YAHOO_ROAD :
				return new YahooRoadMapProvider();

			case MapProviders.YAHOO_AERIAL :
				return new YahooAerialMapProvider();

			case MapProviders.YAHOO_HYBRID :
				return new YahooHybridMapProvider();

			case MapProviders.ZOOMIFY :
			//	return new ZoomifyMapProvider();
				
			default :
				trace ( this.toString() + ": invalid MapProvider requested: " + mapProviderType);
				return null;
		}
	}
}