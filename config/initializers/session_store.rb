# The auth setup changed during early development (added the User Devise scope
# after sessions already existed), which left some browsers holding session
# cookies in an incompatible format — Devise then reads warden.user with the
# wrong arity and raises ArgumentError. Bumping the cookie key makes Rails ignore
# every pre-existing cookie, so stale sessions resolve to "logged out" (a clean
# redirect to sign-in) instead of a 500. Bump the suffix again if it recurs.
Rails.application.config.session_store :cookie_store, key: "_open_session_session_v2"
