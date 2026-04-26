const {
  searchPapers,
  trendingPapers,
  categorySearch,
} = require("../services/papers");

/*
====================================================
Handle Full Search
====================================================
*/
async function handleSearch(req, res) {
  try {
    const data = req.query;

    const result = await searchPapers({
      keyword: data.keyword || "",
      author: data.author || "",
      category: data.category || "",
      year: data.year || "",
      journal: data.journal || "",
      language: data.language || "",
      sort: data.sort || "newest",
      limit: data.limit || 20,
    });

    return res.json(result);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
}

/*
====================================================
Trending Papers
====================================================
*/
async function handleTrending(req, res) {
  try {
    const result = await trendingPapers();
    return res.json(result);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
}

/*
====================================================
Category Only Search
====================================================
*/
async function handleCategory(req, res) {
  try {
    const result = await categorySearch(
      req.query.category || "",
      req.query.language || ""
    );

    return res.json(result);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
}

module.exports = {
  handleSearch,
  handleTrending,
  handleCategory,
};