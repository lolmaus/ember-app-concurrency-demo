import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import type ApiService from 'ember-app-concurrency-demo/services/api';
import { on } from '@ember/modifier';
import perform from 'ember-concurrency/helpers/perform';

export default class Component2 extends Component {
  @service api!: ApiService;

  <template>
    <div
      style="
        border: 2px solid black;
        padding: 2em;
      "
      ...attributes
    >
      <button
        type="button"
        disabled={{this.api.requestGitHubRateLimitTask.isRunning}}
        {{on "click" (perform this.api.requestGitHubRateLimitTask)}}
      >
        Request GitHub rate limit
      </button>

      <p>
        {{#if this.api.requestGitHubRateLimitTask.lastSuccessful}}
          Rate limit: {{this.api.requestGitHubRateLimitTask.lastSuccessful.value}}
        {{/if}}

        {{#if this.api.requestGitHubRateLimitTask.isRunning}}
          Updating...
        {{else if this.api.requestGitHubRateLimitTask.last.error}}
          {{! ToDo: implement error parsing}}
          Error: {{this.api.requestGitHubRateLimitTask.last.error}}
        {{else if this.api.requestGitHubRateLimitTask.isIdle}}
          Idle
        {{else}}
          This should be unreachable
        {{/if}}
      </p>
    </div>
  </template>
}