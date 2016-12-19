Feature: Failing steps

  Background:
    Given a file named "features/fail.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a failing step
      """

  Scenario: too few arguments
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a (.*) step$/, function() {})
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      function has 0 arguments, should have 1 (if synchronous or returning a promise) or 2 (if accepting a callback)
      """

  Scenario: too many arguments
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function(arg1, arg2) {})
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      function has 2 arguments, should have 0 (if synchronous or returning a promise) or 1 (if accepting a callback)
      """

  Scenario: synchronous - throws
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function() {
          throw new Error('my error');
        })
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      my error
      """

  Scenario: asynchronous - throws
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function(callback) {
          setTimeout(function() {
            throw new Error('my error')
          })
        })
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      my error
      """

  Scenario: asynchronous - passing error as first argument to the callback
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function(callback) {
          setTimeout(function() {
            callback(new Error('my error'))
          })
        })
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      my error
      """

  Scenario: asynchronous - using a callback and returning a promise
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function(callback) {
          return {
            then: function(resolve, reject) {}
          }
        })
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      function uses multiple asynchronous interfaces: callback and promise
      """

  Scenario: promise - throws
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function() {
          return {
            then: function(resolve, reject) {
              setTimeout(function() {
                throw new Error('my error')
              })
            }
          }
        })
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      my error
      """

  Scenario: promise - rejects
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a failing step$/, function() {
          return {
            then: function(resolve, reject) {
              setTimeout(function() {
                reject(new Error('my error'))
              })
            }
          }
        })
      })
      """
    When I run cucumber.js
    Then the step "a failing step" failed with:
      """
      my error
      """
