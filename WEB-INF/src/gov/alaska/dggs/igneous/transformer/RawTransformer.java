package gov.alaska.dggs.igneous.transformer;

import flexjson.transformer.AbstractTransformer;
import flexjson.JSONContext;

// Takes in a string and places it, unchanged, into the json.
// This is only appropriate for string that already contain proper
// json
public class RawTransformer extends AbstractTransformer
{
	@Override
	public Boolean isInline(){ return false; }

	@Override
	public void transform(Object o){
		// Do nothing to null values
		if(o == null) return;
		
		JSONContext ctx = getContext();
		ctx.write((String)o);
	}
}
