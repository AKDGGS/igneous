 L.Control.SearchControl = L.Control.extend({
		options: {
			position: 'topleft',
			placeholder: 'Search for .. ',
			menubutton: false,
			inputname: 'q',
			onMenuButton: function(){ /* By default, do nothing */ },
			onSubmit: function(e){
				if('preventDefault' in e) e.preventDefault();
				return false;
			}
		},
		initialize: function(options){
			L.Util.setOptions(this, options);
		},
		onAdd: function(map){
			var container = L.DomUtil.create('div', 'search-container');
			this.form = L.DomUtil.create('form', 'form', container);
			this.form.onsubmit = this.options.onSubmit;

			var inputcontainer = L.DomUtil.create('div', 'search-input-container', this.form);

			if(this.options.menubutton){
				var menubutton = L.DomUtil.create('button', 'search-menu-button', inputcontainer);
				menubutton.setAttribute('type', 'button');
				menubutton.setAttribute('title', 'Toggle Advanced Search Options');
				menubutton.onclick = this.options.onMenuButton;

				var img = L.DomUtil.create('img', 'search-menu-image', menubutton);
				img.src = 'images/menu-2x.png';
			}

			var input = L.DomUtil.create('input', 'search-input', inputcontainer);
			input.type = 'text';
			input.id = input.name = this.options.inputname;
			input.setAttribute('placeholder', this.options.placeholder);
			input.setAttribute('autocomplete', 'off');

			var submitbutton = L.DomUtil.create('button', 'search-submit-button', inputcontainer);
			submitbutton.setAttribute('type', 'submit');
			submitbutton.appendChild(document.createTextNode('Search'));

			L.DomEvent.disableClickPropagation(container);
			L.DomEvent.disableScrollPropagation(container);

			return container;
		}
	});

	L.control.searchControl = function(options){
		return new L.Control.SearchControl(options);
	};
