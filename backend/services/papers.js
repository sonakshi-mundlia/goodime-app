const axios = require("axios");

/*
====================================================
CACHE SYSTEM
====================================================
*/
const cache = new Map();
const CACHE_TTL = 12 * 60 * 60 * 1000;

function getCache(key) {
  const data = cache.get(key);
  if (!data) return null;
  if (Date.now() - data.time > CACHE_TTL) {
    cache.delete(key);
    return null;
  }
  return data.value;
}

function setCache(key, value) {
  cache.set(key, { value, time: Date.now() });
}

function buildKey(obj) {
  return JSON.stringify(obj);
}

/*
====================================================
LANG DETECTION (AUTO ONLY)
====================================================
*/
function detectLang(text = "") {
  if (!text) return "en";

  if (/[\u0900-\u097F]/.test(text)) return "hi";
  if (/[\u4e00-\u9fff]/.test(text)) return "zh";
  if (/[\u0600-\u06FF]/.test(text)) return "ar";
  if (/[\u0400-\u04FF]/.test(text)) return "ru";
  if (/[\u0B80-\u0BFF]/.test(text)) return "ta";
  if (/[\u0C00-\u0C7F]/.test(text)) return "te";
  if (/[\u0A00-\u0A7F]/.test(text)) return "pa";

  return "en";
}

/*
====================================================
QUALITY FILTER
====================================================
*/
function isBadPaper(p) {
  if (!p.title || p.title.length < 8) return true;

  const badPatterns = [
    /^no title$/i,
    /^table \d+/i,
    /^figure \d+/i,
    /^appendix/i,
    /^chapter/i,
  ];

  return badPatterns.some((r) => r.test(p.title));
}

/*
====================================================
DEDUPLICATION
====================================================
*/
function normalizeTitle(title = "") {
  return title.toLowerCase().replace(/[^a-z0-9]/g, "").trim();
}

function dedupe(papers) {
  const map = new Map();
  for (const p of papers) {
    const key = normalizeTitle(p.title);
    if (!map.has(key)) map.set(key, p);
  }
  return Array.from(map.values());
}

/*
====================================================
OPENALEX
====================================================
*/
async function fetchOpenAlex(query, limit) {
  try {
    const res = await axios.get("https://api.openalex.org/works", {
      params: { search: query, per_page: limit },
      timeout: 10000,
    });

    return (res.data.results || []).map((p) => {
      const text = (p.title || "");

      return {
        title: p.title || "",
        authors: (p.authorships || [])
          .map((a) => a.author?.display_name)
          .join(", "),
        year: p.publication_year || null,
        abstract: "Abstract available on source",
        url: p.doi || p.id,
        citations: p.cited_by_count || 0,
        venue: p.primary_location?.source?.display_name || "Unknown",
        language: detectLang(text), // AUTO ONLY
        source: "openalex",
      };
    });
  } catch {
    return [];
  }
}

/*
====================================================
SEMANTIC SCHOLAR
====================================================
*/
async function fetchSemantic(query, limit) {
  try {
    const res = await axios.get(
      "https://api.semanticscholar.org/graph/v1/paper/search",
      {
        params: {
          query,
          limit,
          fields: "title,authors,year,abstract,url,citationCount,venue",
        },
        timeout: 10000,
      }
    );

    return (res.data.data || []).map((p) => ({
      title: p.title || "",
      authors: (p.authors || []).map((a) => a.name).join(", "),
      year: p.year || null,
      abstract: p.abstract || "",
      url: p.url || "",
      citations: p.citationCount || 0,
      venue: p.venue || "Unknown",
      language: detectLang(p.title + " " + (p.abstract || "")),
      source: "semantic-scholar",
    }));
  } catch {
    return [];
  }
}

/*
====================================================
CORE SEARCH (NO LANGUAGE INPUT ANYMORE)
====================================================
*/
async function searchPapers({
  keyword = "",
  category = "",
  year = "",
  sort = "newest",
  limit = 20,
}) {
  const cacheKey = buildKey({ keyword, category, year, sort, limit });

  const cached = getCache(cacheKey);
  if (cached) return cached;

  const query = [keyword, category].filter(Boolean).join(" ") || "science";

  const results = await Promise.all([
    fetchOpenAlex(query, limit),
    fetchSemantic(query, limit),
  ]);

  let papers = results.flat();

  /*
  FILTER QUALITY ONLY
  */
  papers = papers.filter((p) => !isBadPaper(p));

  /*
  YEAR FILTER
  */
  if (year && year !== "all") {
    papers = papers.filter((p) => String(p.year) === String(year));
  }

  /*
  SORTING
  */
  if (sort === "citations") {
    papers.sort((a, b) => b.citations - a.citations);
  } else if (sort === "oldest") {
    papers.sort((a, b) => (a.year || 0) - (b.year || 0));
  } else {
    papers.sort((a, b) => (b.year || 0) - (a.year || 0));
  }

  /*
  DEDUPE
  */
  const finalResults = dedupe(papers).slice(0, limit);

  setCache(cacheKey, finalResults);
  return finalResults;
}

/*
====================================================
CATEGORY SEARCH
====================================================
*/
async function categorySearch(category, limit = 20) {
  return searchPapers({
    category,
    limit,
    sort: "newest",
  });
}

/*
====================================================
TRENDING
====================================================
*/
async function trendingPapers(limit = 10) {
  const topics = [
    "Artificial Intelligence",
    "Quantum Computing",
    "Climate Change",
    "Biotechnology",
    "Renewable Energy",
    "Public Health",
  ];

  const topic = topics[new Date().getDay() % topics.length];

  return searchPapers({
    keyword: topic,
    sort: "citations",
    limit,
  });
}

/*
====================================================
EXPORTS
====================================================
*/
module.exports = {
  searchPapers,
  categorySearch,
  trendingPapers,
};