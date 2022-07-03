import { h } from 'preact';
import { useState, useEffect } from 'preact/hooks';
import { SingleRepo } from './singleRepo';
import { request } from '@utilities/http';
import { i18next } from '@utilities/locale';

export const GithubRepos = () => {
  const [repos, setRepos] = useState([]);
  const [error, setError] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  useEffect(() => {
    getGithubRepos();
  }, []);

  const getGithubRepos = async () => {
    try {
      const response = await request('/github_repos');
      if (response.ok) {
        const repositories = await response.json();
        setRepos(repositories);
      } else {
        throw new Error(response.statusText);
      }
    } catch (error) {
      Honeybadger.notify(error);
      setError(true);
      setErrorMessage(error.toString());
    }
  };

  if (error) {
    return (
      <div className="github-repos github-repos-errored" role="alert">
        {i18next.t('errors.occurred', { error: errorMessage })}
      </div>
    );
  }

  if (repos.length > 0) {
    return (
      <div className="github-repos" data-testid="github-repos-list">
        {repos.map((repo) => (
          <SingleRepo
            key={repo.github_id_code}
            githubIdCode={repo.github_id_code}
            name={repo.name}
            fork={repo.fork}
            featured={repo.featured}
          />
        ))}
      </div>
    );
  }

  return (
    <div
      title={i18next.t('gitHub.loading')}
      className="github-repos loading-repos"
    />
  );
};

GithubRepos.displayName = 'GitHub Repositories Wrapper';
