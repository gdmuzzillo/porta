import React from 'react'
import {LoginMainFooterBandItem} from '@patternfly/react-core'

const ForgotCredentials = ({providerLoginPath}) =>
  <LoginMainFooterBandItem>
    <a href={`${providerLoginPath}?request_password_reset=true`}>Forgot password?</a>
  </LoginMainFooterBandItem>

export {ForgotCredentials}
