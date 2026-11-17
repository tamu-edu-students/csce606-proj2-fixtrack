
import { Head, Link } from "@inertiajs/react";

export default function Home() {
  return (
    <>
      <Head title="FixTrack | Maintenance Management" />

      <div className="min-vh-100 bg-light">
        <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
          <div className="container">
            <Link className="navbar-brand fw-bold" href="/">
              FixTrack
            </Link>

            <div className="ms-auto d-flex gap-2">
              <Link
                href="/users/sign_in"
                className="btn btn-outline-light"
              >
                Log in
              </Link>

              <Link
                href="/users/sign_up"
                className="btn btn-primary"
              >
                Get Started
              </Link>
            </div>
          </div>
        </nav>

        <main>
          <section className="container py-5">
            <div className="row align-items-center min-vh-75">
              <div className="col-lg-7 py-5">
                <span className="badge bg-primary mb-3">
                  Maintenance Management Made Simple
                </span>

                <h1 className="display-3 fw-bold mb-4">
                  Keep your equipment running.
                  <span className="text-primary">
                    {" "}Keep your team connected.
                  </span>
                </h1>

                <p className="lead text-secondary mb-4">
                  FixTrack helps organizations manage maintenance
                  requests, track equipment issues, and coordinate
                  technicians from one centralized platform.
                </p>

                <div className="d-flex gap-3 flex-wrap">
                  <Link
                    href="/users/sign_up"
                    className="btn btn-primary btn-lg"
                  >
                    Get Started
                  </Link>

                  <Link
                    href="/users/sign_in"
                    className="btn btn-outline-dark btn-lg"
                  >
                    Sign In
                  </Link>
                </div>
              </div>

              <div className="col-lg-5">
                <div className="card border-0 shadow-lg">
                  <div className="card-body p-4">
                    <h5 className="fw-bold mb-4">
                      Maintenance Overview
                    </h5>

                    <div className="d-flex justify-content-between mb-3">
                      <span>Open Tickets</span>
                      <span className="badge bg-warning text-dark">
                        12
                      </span>
                    </div>

                    <div className="d-flex justify-content-between mb-3">
                      <span>In Progress</span>
                      <span className="badge bg-primary">
                        5
                      </span>
                    </div>

                    <div className="d-flex justify-content-between mb-3">
                      <span>Completed</span>
                      <span className="badge bg-success">
                        28
                      </span>
                    </div>

                    <hr />

                    <p className="text-secondary mb-0">
                      A centralized place to manage maintenance
                      operations.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </main>
      </div>
    </>
  );
}
