const AppState = {
    isOpen: false,
    type: 'creator',
    forced: false,
    appearance: null,
    config: null,
    outfits: [],
    hasDefault: false,
    currentSection: 'gender',
    debounceTimer: null
};

const Categories = {
    creator: [
        { id: 'gender', name: 'Gender' },
        { id: 'heritage', name: 'Heritage' },
        { id: 'face', name: 'Face Features' },
        { id: 'hair', name: 'Hair' },
        { id: 'eyebrows', name: 'Eyebrows' },
        { id: 'beard', name: 'Facial Hair' },
        { id: 'overlays', name: 'Overlays' },
        { id: 'makeup', name: 'Makeup' },
        { id: 'eyes', name: 'Eye Color' },
        { id: 'components', name: 'Clothing' },
        { id: 'props', name: 'Accessories' },
        { id: 'outfits', name: 'Outfits' }
    ],
    clothing: [
        { id: 'components', name: 'Clothing' },
        { id: 'props', name: 'Accessories' },
        { id: 'outfits', name: 'Outfits' }
    ]
};

window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.action) {
        case 'openMainMenu':
            openMainMenu(data);
            break;
        case 'closeMainMenu':
            closeMainMenu();
            break;
        case 'open':
            openMenu(data);
            break;
        case 'close':
            closeMenu();
            break;
        case 'updateForced':
            AppState.forced = data.forced;
            updateForcedIndicator();
            break;
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (AppState.isOpen) {
            post('escape', {});
        } else if (!document.getElementById('main-menu').classList.contains('hidden')) {
            post('closeMainMenu', {});
        }
    }
});

function openMainMenu(data) {
    document.getElementById('main-menu').classList.remove('hidden');
}

function closeMainMenu() {
    document.getElementById('main-menu').classList.add('hidden');
}

document.getElementById('btn-main-creator').addEventListener('click', () => {
    post('selectCreator', {});
});

document.getElementById('btn-main-clothing').addEventListener('click', () => {
    post('selectClothing', {});
});

document.getElementById('btn-main-close').addEventListener('click', () => {
    post('closeMainMenu', {});
});

function openMenu(data) {
    AppState.isOpen = true;
    AppState.type = data.type;
    AppState.forced = data.forced;
    AppState.appearance = data.appearance;
    AppState.config = data.config;
    AppState.outfits = data.outfits || [];
    AppState.hasDefault = data.hasDefault;
    
    document.getElementById('app').classList.remove('hidden');
    document.getElementById('menu-title').textContent = 
        data.type === 'creator' ? 'CHARACTER CREATOR' : 'CLOTHING MENU';
    
    updateForcedIndicator();
    buildNavigation();
    loadSection(AppState.currentSection);
}

function closeMenu() {
    AppState.isOpen = false;
    document.getElementById('app').classList.add('hidden');
}

function updateForcedIndicator() {
    const indicator = document.getElementById('forced-indicator');
    if (AppState.forced) {
        indicator.classList.add('active');
    } else {
        indicator.classList.remove('active');
    }
}

function buildNavigation() {
    const navSections = document.querySelector('.nav-sections');
    navSections.innerHTML = '';
    
    const categories = Categories[AppState.type];
    
    categories.forEach(cat => {
        const item = document.createElement('div');
        item.className = 'nav-item';
        if (cat.id === AppState.currentSection) {
            item.classList.add('active');
        }
        item.textContent = cat.name;
        item.addEventListener('click', () => {
            document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
            item.classList.add('active');
            loadSection(cat.id);
        });
        navSections.appendChild(item);
    });
}

function loadSection(sectionId) {
    AppState.currentSection = sectionId;
    const contentBody = document.getElementById('content-body');
    const sectionTitle = document.getElementById('section-title');
    
    const category = [...Categories.creator, ...Categories.clothing].find(c => c.id === sectionId);
    sectionTitle.textContent = category ? category.name.toUpperCase() : 'SECTION';
    
    contentBody.innerHTML = '';
    
    switch (sectionId) {
        case 'gender':
            renderGenderSection(contentBody);
            break;
        case 'heritage':
            renderHeritageSection(contentBody);
            break;
        case 'face':
            renderFaceSection(contentBody);
            break;
        case 'hair':
            renderHairSection(contentBody);
            break;
        case 'eyebrows':
            renderEyebrowsSection(contentBody);
            break;
        case 'beard':
            renderBeardSection(contentBody);
            break;
        case 'overlays':
            renderOverlaysSection(contentBody);
            break;
        case 'makeup':
            renderMakeupSection(contentBody);
            break;
        case 'eyes':
            renderEyesSection(contentBody);
            break;
        case 'components':
            renderComponentsSection(contentBody);
            break;
        case 'props':
            renderPropsSection(contentBody);
            break;
        case 'outfits':
            renderOutfitsSection(contentBody);
            break;
    }
}

function renderGenderSection(container) {
    const isMale = AppState.appearance.gender === 'male';
    
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Select Gender</label>
            <div class="gender-selector">
                <div class="gender-btn ${isMale ? 'active' : ''}" data-gender="male">MALE</div>
                <div class="gender-btn ${!isMale ? 'active' : ''}" data-gender="female">FEMALE</div>
            </div>
        </div>
    `;
    
    container.querySelectorAll('.gender-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const gender = btn.dataset.gender;
            post('changeGender', { gender }, (response) => {
                AppState.appearance = response.appearance;
                loadSection('gender');
            });
        });
    });
}

function renderHeritageSection(container) {
    const headBlend = AppState.appearance.headBlend || {};
    
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Mother</label>
            <div class="parent-grid" id="mother-grid"></div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Father</label>
            <div class="parent-grid" id="father-grid"></div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Shape Mix</label>
            <div class="slider-control">
                <input type="range" class="slider" min="0" max="100" value="${(headBlend.shapeMix || 0.5) * 100}" id="shape-mix">
                <span class="slider-value" id="shape-mix-value">${Math.floor((headBlend.shapeMix || 0.5) * 100)}%</span>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Skin Mix</label>
            <div class="slider-control">
                <input type="range" class="slider" min="0" max="100" value="${(headBlend.skinMix || 0.5) * 100}" id="skin-mix">
                <span class="slider-value" id="skin-mix-value">${Math.floor((headBlend.skinMix || 0.5) * 100)}%</span>
            </div>
        </div>
    `;
    
    renderParentGrid('mother-grid', 'shapeFirst', headBlend.shapeFirst || 0);
    renderParentGrid('father-grid', 'shapeSecond', headBlend.shapeSecond || 0);
    
    setupSlider('shape-mix', 'shape-mix-value', (value) => {
        AppState.appearance.headBlend.shapeMix = value / 100;
        updateAppearance();
    }, '%');
    
    setupSlider('skin-mix', 'skin-mix-value', (value) => {
        AppState.appearance.headBlend.skinMix = value / 100;
        updateAppearance();
    }, '%');
}

function renderParentGrid(containerId, key, current) {
    const grid = document.getElementById(containerId);
    const parents = AppState.config.parents[key === 'shapeFirst' ? 'mothers' : 'fathers'];
    
    parents.forEach(id => {
        const option = document.createElement('div');
        option.className = 'parent-option';
        if (id === current) option.classList.add('active');
        option.textContent = id;
        option.addEventListener('click', () => {
            AppState.appearance.headBlend[key] = id;
            if (key === 'shapeFirst') {
                AppState.appearance.headBlend.skinFirst = id;
            } else {
                AppState.appearance.headBlend.skinSecond = id;
            }
            updateAppearance();
            renderHeritageSection(document.getElementById('content-body'));
        });
        grid.appendChild(option);
    });
}

function renderFaceSection(container) {
    const features = AppState.appearance.faceFeatures || {};
    
    const grouped = {};
    AppState.config.faceFeatures.forEach(feature => {
        if (!grouped[feature.category]) grouped[feature.category] = [];
        grouped[feature.category].push(feature);
    });
    
    let html = '';
    
    for (const [category, featureList] of Object.entries(grouped)) {
        html += `<h4 style="color: #aaa; margin: 12px 0 6px 0; font-size: 11px;">${category}</h4>`;
        
        featureList.forEach(feature => {
            const value = features[feature.id] || 0.0;
            html += `
                <div class="control-group">
                    <label class="control-label">${feature.name}</label>
                    <div class="slider-control">
                        <input type="range" class="slider" min="-100" max="100" value="${value * 100}" data-feature="${feature.id}">
                        <span class="slider-value" data-feature-value="${feature.id}">${Math.floor(value * 100)}</span>
                    </div>
                </div>
            `;
        });
    }
    
    container.innerHTML = html;
    
    container.querySelectorAll('.slider').forEach(slider => {
        const featureId = parseInt(slider.dataset.feature);
        slider.addEventListener('input', (e) => {
            const value = parseFloat(e.target.value) / 100;
            AppState.appearance.faceFeatures[featureId] = value;
            container.querySelector(`[data-feature-value="${featureId}"]`).textContent = Math.floor(e.target.value);
            updateAppearance();
        });
    });
}

function renderHairSection(container) {
    const hairComponent = AppState.appearance.components[2] || { drawable: 0, texture: 0 };
    const hairColor = AppState.appearance.hairColor || { primary: 0, highlight: 0 };
    
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Hair Style</label>
            <div class="index-control">
                <button class="btn-arrow" data-action="prev-hair-style">◄</button>
                <span class="index-value" id="hair-style-value">Style: ${hairComponent.drawable}</span>
                <button class="btn-arrow" data-action="next-hair-style">►</button>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Hair Texture</label>
            <div class="index-control">
                <button class="btn-arrow" data-action="prev-hair-texture">◄</button>
                <span class="index-value" id="hair-texture-value">Texture: ${hairComponent.texture}</span>
                <button class="btn-arrow" data-action="next-hair-texture">►</button>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Primary Color</label>
            <div class="index-control">
                <button class="btn-arrow" data-action="prev-hair-primary">◄</button>
                <span class="index-value" id="hair-primary-value">Color: ${hairColor.primary}</span>
                <button class="btn-arrow" data-action="next-hair-primary">►</button>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Highlight Color</label>
            <div class="index-control">
                <button class="btn-arrow" data-action="prev-hair-highlight">◄</button>
                <span class="index-value" id="hair-highlight-value">Color: ${hairColor.highlight}</span>
                <button class="btn-arrow" data-action="next-hair-highlight">►</button>
            </div>
        </div>
    `;
    
    container.querySelector('[data-action="prev-hair-style"]').addEventListener('click', () => changeComponent(2, -1, 0));
    container.querySelector('[data-action="next-hair-style"]').addEventListener('click', () => changeComponent(2, 1, 0));
    container.querySelector('[data-action="prev-hair-texture"]').addEventListener('click', () => changeComponent(2, 0, -1));
    container.querySelector('[data-action="next-hair-texture"]').addEventListener('click', () => changeComponent(2, 0, 1));
    container.querySelector('[data-action="prev-hair-primary"]').addEventListener('click', () => changeHairColor('primary', -1));
    container.querySelector('[data-action="next-hair-primary"]').addEventListener('click', () => changeHairColor('primary', 1));
    container.querySelector('[data-action="prev-hair-highlight"]').addEventListener('click', () => changeHairColor('highlight', -1));
    container.querySelector('[data-action="next-hair-highlight"]').addEventListener('click', () => changeHairColor('highlight', 1));
}

function renderEyebrowsSection(container) {
    const overlay = AppState.appearance.overlays[2] || { index: 0, opacity: 0.0, color: 0 };
    
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Eyebrow Style</label>
            <div class="index-control">
                <button class="btn-arrow" data-overlay="2" data-prop="index" data-dir="-1">◄</button>
                <span class="index-value">Style: ${overlay.index}</span>
                <button class="btn-arrow" data-overlay="2" data-prop="index" data-dir="1">►</button>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Opacity</label>
            <div class="slider-control">
                <input type="range" class="slider" min="0" max="100" value="${overlay.opacity * 100}" data-overlay="2" data-prop="opacity">
                <span class="slider-value">${Math.floor(overlay.opacity * 100)}%</span>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Color</label>
            <div class="index-control">
                <button class="btn-arrow" data-overlay="2" data-prop="color" data-dir="-1">◄</button>
                <span class="index-value">Color: ${overlay.color}</span>
                <button class="btn-arrow" data-overlay="2" data-prop="color" data-dir="1">►</button>
            </div>
        </div>
    `;
    
    setupOverlayControls(container);
}

function renderBeardSection(container) {
    const isMale = AppState.appearance.gender === 'male';
    
    if (!isMale) {
        container.innerHTML = '<p style="color: #888; font-size: 11px;">Facial hair is only available for male characters.</p>';
        return;
    }
    
    const overlay = AppState.appearance.overlays[1] || { index: 0, opacity: 0.0, color: 0 };
    
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Beard Style</label>
            <div class="index-control">
                <button class="btn-arrow" data-overlay="1" data-prop="index" data-dir="-1">◄</button>
                <span class="index-value">Style: ${overlay.index}</span>
                <button class="btn-arrow" data-overlay="1" data-prop="index" data-dir="1">►</button>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Opacity</label>
            <div class="slider-control">
                <input type="range" class="slider" min="0" max="100" value="${overlay.opacity * 100}" data-overlay="1" data-prop="opacity">
                <span class="slider-value">${Math.floor(overlay.opacity * 100)}%</span>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label">Color</label>
            <div class="index-control">
                <button class="btn-arrow" data-overlay="1" data-prop="color" data-dir="-1">◄</button>
                <span class="index-value">Color: ${overlay.color}</span>
                <button class="btn-arrow" data-overlay="1" data-prop="color" data-dir="1">►</button>
            </div>
        </div>
    `;
    
    setupOverlayControls(container);
}

function renderOverlaysSection(container) {
    const overlayIds = [0, 3, 6, 7, 9, 11];
    const isMale = AppState.appearance.gender === 'male';
    if (isMale) overlayIds.push(10);
    
    let html = '';
    
    overlayIds.forEach(id => {
        const overlayConfig = AppState.config.overlays.find(o => o.id === id);
        const overlay = AppState.appearance.overlays[id] || { index: 0, opacity: 0.0, color: 0 };
        
        html += `
            <h4 style="color: #aaa; margin: 12px 0 6px 0; font-size: 11px;">${overlayConfig.name}</h4>
            <div class="control-group">
                <label class="control-label">Style</label>
                <div class="index-control">
                    <button class="btn-arrow" data-overlay="${id}" data-prop="index" data-dir="-1">◄</button>
                    <span class="index-value">Style: ${overlay.index}</span>
                    <button class="btn-arrow" data-overlay="${id}" data-prop="index" data-dir="1">►</button>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">Opacity</label>
                <div class="slider-control">
                    <input type="range" class="slider" min="0" max="100" value="${overlay.opacity * 100}" data-overlay="${id}" data-prop="opacity">
                    <span class="slider-value">${Math.floor(overlay.opacity * 100)}%</span>
                </div>
            </div>
        `;
        
        if (overlayConfig.colorType > 0) {
            html += `
                <div class="control-group">
                    <label class="control-label">Color</label>
                    <div class="index-control">
                        <button class="btn-arrow" data-overlay="${id}" data-prop="color" data-dir="-1">◄</button>
                        <span class="index-value">Color: ${overlay.color}</span>
                        <button class="btn-arrow" data-overlay="${id}" data-prop="color" data-dir="1">►</button>
                    </div>
                </div>
            `;
        }
        
        html += '<div class="section-divider"></div>';
    });
    
    container.innerHTML = html;
    setupOverlayControls(container);
}

function renderMakeupSection(container) {
    const overlayIds = [4, 5, 8];
    
    let html = '';
    
    overlayIds.forEach(id => {
        const overlayConfig = AppState.config.overlays.find(o => o.id === id);
        const overlay = AppState.appearance.overlays[id] || { index: 0, opacity: 0.0, color: 0 };
        
        html += `
            <h4 style="color: #aaa; margin: 12px 0 6px 0; font-size: 11px;">${overlayConfig.name}</h4>
            <div class="control-group">
                <label class="control-label">Style</label>
                <div class="index-control">
                    <button class="btn-arrow" data-overlay="${id}" data-prop="index" data-dir="-1">◄</button>
                    <span class="index-value">Style: ${overlay.index}</span>
                    <button class="btn-arrow" data-overlay="${id}" data-prop="index" data-dir="1">►</button>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">Opacity</label>
                <div class="slider-control">
                    <input type="range" class="slider" min="0" max="100" value="${overlay.opacity * 100}" data-overlay="${id}" data-prop="opacity">
                    <span class="slider-value">${Math.floor(overlay.opacity * 100)}%</span>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">Color</label>
                <div class="index-control">
                    <button class="btn-arrow" data-overlay="${id}" data-prop="color" data-dir="-1">◄</button>
                    <span class="index-value">Color: ${overlay.color}</span>
                    <button class="btn-arrow" data-overlay="${id}" data-prop="color" data-dir="1">►</button>
                </div>
            </div>
            <div class="section-divider"></div>
        `;
    });
    
    container.innerHTML = html;
    setupOverlayControls(container);
}

function renderEyesSection(container) {
    const eyeColor = AppState.appearance.eyeColor || 0;
    
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Eye Color</label>
            <div class="index-control">
                <button class="btn-arrow" id="eye-prev">◄</button>
                <span class="index-value" id="eye-value">Color: ${eyeColor}</span>
                <button class="btn-arrow" id="eye-next">►</button>
            </div>
        </div>
    `;
    
    container.querySelector('#eye-prev').addEventListener('click', () => {
        let newColor = AppState.appearance.eyeColor - 1;
        if (newColor < 0) newColor = AppState.config.eyeColors.max;
        AppState.appearance.eyeColor = newColor;
        updateAppearance();
        container.querySelector('#eye-value').textContent = `Color: ${newColor}`;
    });
    
    container.querySelector('#eye-next').addEventListener('click', () => {
        let newColor = AppState.appearance.eyeColor + 1;
        if (newColor > AppState.config.eyeColors.max) newColor = 0;
        AppState.appearance.eyeColor = newColor;
        updateAppearance();
        container.querySelector('#eye-value').textContent = `Color: ${newColor}`;
    });
}

function renderComponentsSection(container) {
    let html = '';
    
    AppState.config.components.forEach(component => {
        const data = AppState.appearance.components[component.id] || { drawable: 0, texture: 0 };
        
        html += `
            <div class="control-group">
                <label class="control-label">${component.name}</label>
                <div class="control-row">
                    <button class="btn-arrow" data-component="${component.id}" data-prop="drawable" data-dir="-1">◄</button>
                    <span class="index-value" style="flex: 1;">Draw: ${data.drawable}</span>
                    <button class="btn-arrow" data-component="${component.id}" data-prop="drawable" data-dir="1">►</button>
                </div>
                <div class="control-row">
                    <button class="btn-arrow" data-component="${component.id}" data-prop="texture" data-dir="-1">◄</button>
                    <span class="index-value" style="flex: 1;">Text: ${data.texture}</span>
                    <button class="btn-arrow" data-component="${component.id}" data-prop="texture" data-dir="1">►</button>
                </div>
            </div>
        `;
    });
    
    container.innerHTML = html;
    
    container.querySelectorAll('.btn-arrow[data-component]').forEach(btn => {
        btn.addEventListener('click', () => {
            const componentId = parseInt(btn.dataset.component);
            const prop = btn.dataset.prop;
            const dir = parseInt(btn.dataset.dir);
            
            changeComponent(componentId, prop === 'drawable' ? dir : 0, prop === 'texture' ? dir : 0);
        });
    });
}

function renderPropsSection(container) {
    let html = '';
    
    AppState.config.props.forEach(prop => {
        const data = AppState.appearance.props[prop.id] || { drawable: -1, texture: 0 };
        
        html += `
            <div class="control-group">
                <label class="control-label">${prop.name}</label>
                <button class="btn btn-secondary btn-small" data-prop="${prop.id}" data-action="clear">Remove</button>
                <div class="control-row">
                    <button class="btn-arrow" data-prop-id="${prop.id}" data-prop="drawable" data-dir="-1">◄</button>
                    <span class="index-value" style="flex: 1;">Draw: ${data.drawable}</span>
                    <button class="btn-arrow" data-prop-id="${prop.id}" data-prop="drawable" data-dir="1">►</button>
                </div>
                <div class="control-row">
                    <button class="btn-arrow" data-prop-id="${prop.id}" data-prop="texture" data-dir="-1">◄</button>
                    <span class="index-value" style="flex: 1;">Text: ${data.texture}</span>
                    <button class="btn-arrow" data-prop-id="${prop.id}" data-prop="texture" data-dir="1">►</button>
                </div>
            </div>
        `;
    });
    
    container.innerHTML = html;
    
    container.querySelectorAll('[data-action="clear"]').forEach(btn => {
        btn.addEventListener('click', () => {
            const propId = parseInt(btn.dataset.prop);
            AppState.appearance.props[propId] = { drawable: -1, texture: -1 };
            post('updateProp', { propId, drawable: -1, texture: -1 });
            renderPropsSection(container);
        });
    });
    
    container.querySelectorAll('.btn-arrow[data-prop-id]').forEach(btn => {
        btn.addEventListener('click', () => {
            const propId = parseInt(btn.dataset.propId);
            const prop = btn.dataset.prop;
            const dir = parseInt(btn.dataset.dir);
            
            changeProp(propId, prop === 'drawable' ? dir : 0, prop === 'texture' ? dir : 0);
        });
    });
}

function renderOutfitsSection(container) {
    container.innerHTML = `
        <div class="control-group">
            <label class="control-label">Save Current Outfit</label>
            <div class="control-row">
                <input type="text" class="input-field" id="outfit-name" placeholder="Enter outfit name...">
                <button class="btn btn-success btn-small" id="save-outfit">Save</button>
            </div>
        </div>
        
        <div class="section-divider"></div>
        
        <div class="control-group">
            <label class="control-label">Saved Outfits</label>
            <div class="outfit-list" id="outfit-list"></div>
        </div>
    `;
    
    const outfitList = container.querySelector('#outfit-list');
    
    if (AppState.outfits.length === 0) {
        outfitList.innerHTML = '<p style="color: #888; font-size: 10px;">No outfits saved yet.</p>';
    } else {
        AppState.outfits.forEach(name => {
            const item = document.createElement('div');
            item.className = 'outfit-item';
            item.innerHTML = `
                <span class="outfit-name">${name}</span>
                <div class="outfit-actions">
                    <button class="btn btn-info btn-small" data-outfit="${name}" data-action="load">Load</button>
                    <button class="btn btn-danger btn-small" data-outfit="${name}" data-action="delete">Del</button>
                </div>
            `;
            outfitList.appendChild(item);
        });
        
        outfitList.querySelectorAll('[data-action="load"]').forEach(btn => {
            btn.addEventListener('click', () => {
                const name = btn.dataset.outfit;
                post('loadOutfit', { name }, (response) => {
                    if (response.success) {
                        AppState.appearance = response.appearance;
                    }
                });
            });
        });
        
        outfitList.querySelectorAll('[data-action="delete"]').forEach(btn => {
            btn.addEventListener('click', () => {
                const name = btn.dataset.outfit;
                post('deleteOutfit', { name }, (response) => {
                    if (response.success) {
                        AppState.outfits = response.outfits;
                        renderOutfitsSection(container);
                    }
                });
            });
        });
    }
    
    container.querySelector('#save-outfit').addEventListener('click', () => {
        const name = container.querySelector('#outfit-name').value.trim();
        if (!name) return;
        
        post('saveOutfit', { name }, (response) => {
            if (response.success) {
                AppState.outfits = response.outfits;
                container.querySelector('#outfit-name').value = '';
                renderOutfitsSection(container);
            }
        });
    });
}

function setupSlider(sliderId, valueId, callback, suffix = '') {
    const slider = document.getElementById(sliderId);
    const valueDisplay = document.getElementById(valueId);
    
    slider.addEventListener('input', (e) => {
        const value = parseFloat(e.target.value);
        valueDisplay.textContent = Math.floor(value) + suffix;
        callback(value);
    });
}

function setupOverlayControls(container) {
    container.querySelectorAll('.btn-arrow[data-overlay]').forEach(btn => {
        btn.addEventListener('click', () => {
            const overlayId = parseInt(btn.dataset.overlay);
            const prop = btn.dataset.prop;
            const dir = parseInt(btn.dataset.dir);
            
            const overlay = AppState.appearance.overlays[overlayId] || { index: 0, opacity: 0.0, color: 0 };
            const overlayConfig = AppState.config.overlays.find(o => o.id === overlayId);
            
            if (prop === 'index') {
                let newIndex = overlay.index + dir;
                if (newIndex < 0) newIndex = overlayConfig.maxIndex;
                if (newIndex > overlayConfig.maxIndex) newIndex = 0;
                overlay.index = newIndex;
            } else if (prop === 'color') {
                let newColor = overlay.color + dir;
                if (newColor < 0) newColor = 63;
                if (newColor > 63) newColor = 0;
                overlay.color = newColor;
            }
            
            AppState.appearance.overlays[overlayId] = overlay;
            updateAppearance();
            
            btn.parentElement.querySelector('.index-value').textContent = 
                prop === 'index' ? `Style: ${overlay.index}` : `Color: ${overlay.color}`;
        });
    });
    
    container.querySelectorAll('.slider[data-overlay]').forEach(slider => {
        slider.addEventListener('input', (e) => {
            const overlayId = parseInt(slider.dataset.overlay);
            const value = parseFloat(e.target.value) / 100;
            
            const overlay = AppState.appearance.overlays[overlayId] || { index: 0, opacity: 0.0, color: 0 };
            overlay.opacity = value;
            AppState.appearance.overlays[overlayId] = overlay;
            
            slider.parentElement.querySelector('.slider-value').textContent = Math.floor(e.target.value) + '%';
            updateAppearance();
        });
    });
}

function changeComponent(componentId, drawableDir, textureDir) {
    const component = AppState.appearance.components[componentId] || { drawable: 0, texture: 0 };
    
    if (drawableDir !== 0) {
        component.drawable = Math.max(0, component.drawable + drawableDir);
        component.texture = 0;
    } else if (textureDir !== 0) {
        component.texture = Math.max(0, component.texture + textureDir);
    }
    
    AppState.appearance.components[componentId] = component;
    
    post('updateComponent', {
        componentId,
        drawable: component.drawable,
        texture: component.texture
    }, (response) => {
        if (component.drawable > response.maxDrawable) {
            component.drawable = 0;
        }
        if (component.texture > response.maxTexture) {
            component.texture = 0;
        }
        
        renderComponentsSection(document.getElementById('content-body'));
    });
}

function changeProp(propId, drawableDir, textureDir) {
    const prop = AppState.appearance.props[propId] || { drawable: -1, texture: 0 };
    
    if (drawableDir !== 0) {
        prop.drawable = prop.drawable + drawableDir;
        if (prop.drawable < -1) prop.drawable = -1;
        prop.texture = 0;
    } else if (textureDir !== 0) {
        prop.texture = Math.max(0, prop.texture + textureDir);
    }
    
    AppState.appearance.props[propId] = prop;
    
    post('updateProp', {
        propId,
        drawable: prop.drawable,
        texture: prop.texture
    }, (response) => {
        if (prop.drawable > response.maxDrawable) {
            prop.drawable = -1;
        }
        if (prop.texture > response.maxTexture) {
            prop.texture = 0;
        }
        
        renderPropsSection(document.getElementById('content-body'));
    });
}

function changeHairColor(type, dir) {
    const hairColor = AppState.appearance.hairColor || { primary: 0, highlight: 0 };
    
    let newColor = hairColor[type] + dir;
    if (newColor < 0) newColor = 63;
    if (newColor > 63) newColor = 0;
    
    hairColor[type] = newColor;
    AppState.appearance.hairColor = hairColor;
    
    updateAppearance();
    
    document.getElementById(`hair-${type}-value`).textContent = `Color: ${newColor}`;
}

function updateAppearance() {
    clearTimeout(AppState.debounceTimer);
    AppState.debounceTimer = setTimeout(() => {
        post('updateAppearance', { appearance: AppState.appearance });
    }, 50);
}

document.getElementById('btn-save').addEventListener('click', () => {
    post('save', {});
});

document.getElementById('btn-set-default').addEventListener('click', () => {
    post('setDefault', {}, (response) => {
        AppState.hasDefault = response.hasDefault;
    });
});

document.getElementById('btn-load-default').addEventListener('click', () => {
    post('loadDefault', {}, (response) => {
        if (response.appearance) {
            AppState.appearance = response.appearance;
            loadSection(AppState.currentSection);
        }
    });
});

document.getElementById('btn-close').addEventListener('click', () => {
    post('close', {});
});

document.getElementById('cam-rotate-left').addEventListener('click', () => {
    post('rotateCamera', { direction: -1 });
});

document.getElementById('cam-rotate-right').addEventListener('click', () => {
    post('rotateCamera', { direction: 1 });
});

document.getElementById('cam-face').addEventListener('click', () => {
    post('setCameraMode', { mode: 'face' });
});

document.getElementById('cam-body').addEventListener('click', () => {
    post('setCameraMode', { mode: 'body' });
});

document.getElementById('cam-legs').addEventListener('click', () => {
    post('setCameraMode', { mode: 'legs' });
});

document.getElementById('cam-feet').addEventListener('click', () => {
    post('setCameraMode', { mode: 'feet' });
});

function post(endpoint, data, callback) {
    fetch(`https://koumarianos_appearance/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(resp => resp.json())
    .then(callback || (() => {}))
    .catch(console.error);
}