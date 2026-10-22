import jenkins.model.Jenkins
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy

def j = Jenkins.get()
def realm = new HudsonPrivateSecurityRealm(false)
realm.createAccount("admin", System.getenv("JENKINS_ADMIN_PASSWORD"))
j.setSecurityRealm(realm)
def auth = new FullControlOnceLoggedInAuthorizationStrategy()
auth.setAllowAnonymousRead(true)          // lets the CI take screenshots of the dashboard without logging in
j.setAuthorizationStrategy(auth)
j.setNumExecutors(2)
j.save()
