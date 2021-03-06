package gov.alaska.dggs.igneous.transformer;

import flexjson.BasicType;
import flexjson.TypeContext;
import flexjson.transformer.AbstractTransformer;

// Works exactly as FlexJSON's standard IterableTransformer
// except it excludes empty arrays
public class IterableTransformer extends AbstractTransformer
{
	@Override
	public Boolean isInline(){ return true; }


	@Override
	public void transform(Object object)
	{
		Iterable iterable = (Iterable) object;
		if(iterable.iterator().hasNext() || getContext().getPath().length() == 0){
			TypeContext typeContext = getContext().peekTypeContext();
			if(typeContext != null){
				if(!typeContext.isFirst()) getContext().writeComma();
				typeContext.increment();
				getContext().writeName(typeContext.getPropertyName());
			}

			typeContext = getContext().writeOpenArray();
			for (Object item : iterable) {
				if(!typeContext.isFirst()) getContext().writeComma();
				typeContext.increment();
				getContext().transform(item);
			}
			getContext().writeCloseArray();
		}
	}
}
