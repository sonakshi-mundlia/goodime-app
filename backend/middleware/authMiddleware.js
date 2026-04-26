const jwt = require("jsonwebtoken");

module.exports = function (req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    // Check header exists
    if (!authHeader) {
      return res.status(401).json({ error: "No authorization header" });
    }

    // Format: Bearer token
    const token = authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({ error: "No token provided" });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user data to request
    req.user = {
      id: decoded.id || decoded.user || decoded._id,
      email: decoded.email,
    };

    next();
  } catch (err) {
    return res.status(401).json({
      error: "Unauthorized - Invalid token",
    });
  }
};
