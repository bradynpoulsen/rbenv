#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${RBENV_ROOT}/version" ]
  run rbenv-version-origin
  assert_success "${RBENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$RBENV_ROOT"
  touch "${RBENV_ROOT}/version"
  run rbenv-version-origin
  assert_success "${RBENV_ROOT}/version"
}

@test "detects RBENV_VERSION" {
  RBENV_VERSION=1 run rbenv-version-origin
  assert_success "RBENV_VERSION environment variable"
}

@test "detects local file" {
  touch .ruby-version
  run rbenv-version-origin
  assert_success "${PWD}/.ruby-version"
}

@test "detects alternate version file" {
  touch .rbenv-version
  run rbenv-version-origin
  assert_success "${PWD}/.rbenv-version"
}

@test "reports from hook" {
  mkdir -p "${RBENV_ROOT}/rbenv.d/version-origin"
  cat > "${RBENV_ROOT}/rbenv.d/version-origin/test.bash" <<HOOK
RBENV_VERSION_ORIGIN=plugin
HOOK

  RBENV_VERSION=1 RBENV_HOOK_PATH="${RBENV_ROOT}/rbenv.d" run rbenv-version-origin
  assert_success "plugin"
}

@test "doesn't inherit RBENV_VERSION_ORIGIN from environment" {
  RBENV_VERSION_ORIGIN=ignored run rbenv-version-origin
  assert_success "${RBENV_ROOT}/version"
}
