// @flow

import React from 'react'
import {Label} from 'NewService/components/FormElements'
import type {Api} from 'Types/Api'

type Props = {
  backendApis: Api[]
}

const BackendApiSelect = ({backendApis}: Props) => {
  return (
    <React.Fragment>
      <li id="service_backend_api_input">
        <Label
          htmlFor='service_backend_api'
          label='Backend API'
        />
        <select name="service[backend_api_id]" id="service_backend_api">
          <option key='empty' value=''></option>
          {backendApis.map(({id, name}) => <option key={id} value={id}>{name}</option>)}
        </select>
      </li>
    </React.Fragment>
  )
}

export {BackendApiSelect}
