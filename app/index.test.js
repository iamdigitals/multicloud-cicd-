const request = require("supertest");
const app = require("./index");

describe("API Endpoints", () => {
  test("GET / returns healthy status", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("healthy");
    expect(res.body.service).toBe("multicloud-cicd-demo");
  });

  test("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("ok");
  });
});
