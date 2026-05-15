const infoBox = document.getElementById('countryInfo');
const globeContainer = document.getElementById('globeViz');

const COUNTRY_GEOJSON_URL =
  'https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson';

const COUNTRY_NAME_ALIASES = {
  'United States of America': 'United States',
  Russia: 'Russian Federation',
  'Democratic Republic of the Congo': 'Congo (Democratic Republic of the)',
  'Republic of the Congo': 'Congo',
  'Czech Republic': 'Czechia',
  'Republic of Serbia': 'Serbia',
  'Bosnia and Herz.': 'Bosnia and Herzegovina',
  'Dominican Rep.': 'Dominican Republic',
  'Central African Rep.': 'Central African Republic',
  'Eq. Guinea': 'Equatorial Guinea',
  'S. Sudan': 'South Sudan',
  'Solomon Is.': 'Solomon Islands',
  'eSwatini': 'Eswatini',
  'N. Cyprus': 'Cyprus'
};

let activeCountry = null;

const formatNumber = value =>
  typeof value === 'number' ? new Intl.NumberFormat('fr-FR').format(value) : 'N/A';

const normalizeCountryName = name => COUNTRY_NAME_ALIASES[name] ?? name;

const readIsoCode = feature => {
  const props = feature?.properties ?? {};
  const rawIso = props.iso_a2 ?? props.ISO_A2 ?? props.adm0_a3 ?? props.ISO_A3 ?? props.iso3;
  if (!rawIso || rawIso === '-99') return null;
  return String(rawIso).trim();
};

const showLoading = countryName => {
  infoBox.innerHTML = `
    <h2>${countryName}</h2>
    <p>Chargement des informations...</p>
  `;
};

const showCountryInfo = ({ name, capital, region, population, currencies, languages, flag }) => {
  infoBox.innerHTML = `
    <h2>${flag ?? '🌐'} ${name ?? 'Pays inconnu'}</h2>
    <dl>
      <dt>Capitale</dt><dd>${capital ?? 'N/A'}</dd>
      <dt>Région</dt><dd>${region ?? 'N/A'}</dd>
      <dt>Population</dt><dd>${formatNumber(population)}</dd>
      <dt>Monnaie</dt><dd>${currencies ?? 'N/A'}</dd>
      <dt>Langues</dt><dd>${languages ?? 'N/A'}</dd>
    </dl>
  `;
};

const showError = message => {
  infoBox.innerHTML = `
    <h2>Erreur</h2>
    <p class="error">${message}</p>
  `;
};

const fetchJSON = async url => {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json();
};

async function fetchCountryData(feature) {
  const clickedName = feature.properties?.name ?? 'Pays inconnu';
  const normalizedName = normalizeCountryName(clickedName);
  const isoCode = readIsoCode(feature);

  if (isoCode) {
    try {
      const byIso = await fetchJSON(
        `https://restcountries.com/v3.1/alpha/${encodeURIComponent(isoCode)}`
      );
      return Array.isArray(byIso) ? byIso[0] : byIso;
    } catch {
      // Fallback on name lookup below
    }
  }

  const exactCandidates = [normalizedName, clickedName];

  for (const candidate of exactCandidates) {
    try {
      const exact = await fetchJSON(
        `https://restcountries.com/v3.1/name/${encodeURIComponent(candidate)}?fullText=true`
      );
      if (exact?.[0]) return exact[0];
    } catch {
      // Continue with broader match
    }
  }

  for (const candidate of exactCandidates) {
    try {
      const broad = await fetchJSON(
        `https://restcountries.com/v3.1/name/${encodeURIComponent(candidate)}`
      );
      if (broad?.[0]) return broad[0];
    } catch {
      // Keep trying
    }
  }

  throw new Error(`Informations introuvables pour ${clickedName}.`);
}

function mapCountryDetails(data, fallbackName) {
  const currencies = data.currencies
    ? Object.values(data.currencies)
        .map(cur => `${cur.name} (${cur.symbol ?? '-'})`)
        .join(', ')
    : null;

  const languages = data.languages ? Object.values(data.languages).join(', ') : null;

  return {
    name: data.name?.common ?? fallbackName,
    capital: data.capital?.[0],
    region: data.region,
    population: data.population,
    currencies,
    languages,
    flag: data.flag
  };
}

function initGlobe(countries) {
  const globe = Globe()(globeContainer)
    .globeImageUrl('//unpkg.com/three-globe/example/img/earth-blue-marble.jpg')
    .bumpImageUrl('//unpkg.com/three-globe/example/img/earth-topology.png')
    .backgroundImageUrl('//unpkg.com/three-globe/example/img/night-sky.png');

  if (typeof globe.cloudsImageUrl === 'function') {
    globe.cloudsImageUrl('//unpkg.com/three-globe/example/img/earth-clouds.png');
  }

  if (typeof globe.showAtmosphere === 'function') {
    globe.showAtmosphere(true);
  }
  if (typeof globe.atmosphereColor === 'function') {
    globe.atmosphereColor('#75bfff');
  }
  if (typeof globe.atmosphereAltitude === 'function') {
    globe.atmosphereAltitude(0.2);
  }

  globe.polygonsData(countries.features)
    .polygonCapColor(feature =>
      activeCountry === feature ? 'rgba(255, 213, 79, 0.6)' : 'rgba(87, 169, 255, 0.06)'
    )
    .polygonSideColor(() => 'rgba(0, 100, 255, 0.04)')
    .polygonStrokeColor(feature => (activeCountry === feature ? '#ffd54f' : '#74d2ff'))
    .polygonAltitude(feature => (activeCountry === feature ? 0.02 : 0.008))
    .polygonLabel(
      feature => `<b>${feature.properties.name}</b><br/>Klik 3lih bach tchof ma3loumat.`
    )
    .onPolygonClick(async feature => {
      const countryName = feature.properties.name;
      try {
        activeCountry = feature;
        globe
          .polygonCapColor(globe.polygonCapColor())
          .polygonStrokeColor(globe.polygonStrokeColor())
          .polygonAltitude(globe.polygonAltitude());
        showLoading(countryName);

        const data = await fetchCountryData(feature);
        showCountryInfo(mapCountryDetails(data, countryName));
      } catch (error) {
        showError(error.message || 'Impossible de charger les informations du pays.');
      }
    });

  globe.controls().autoRotate = true;
  globe.controls().autoRotateSpeed = 0.55;
  globe.controls().enableDamping = true;
  globe.controls().dampingFactor = 0.06;

  const directionalLight = globe
    .scene()
    .children.find(obj => obj.type === 'DirectionalLight');
  if (directionalLight) {
    directionalLight.intensity = 1.7;
    directionalLight.position.set(1.2, 0.8, 1.5);
  }

  const ambientLight = globe.scene().children.find(obj => obj.type === 'AmbientLight');
  if (ambientLight) {
    ambientLight.intensity = 0.55;
  }

  const resize = () => {
    globe.width(globeContainer.clientWidth);
    globe.height(globeContainer.clientHeight);
  };

  window.addEventListener('resize', resize);
  resize();
}

(async function bootstrap() {
  try {
    const geojson = await fetchJSON(COUNTRY_GEOJSON_URL);
    initGlobe(geojson);
  } catch (error) {
    showError(error.message || "Erreur inconnue lors de l'initialisation du globe.");
  }
})();
