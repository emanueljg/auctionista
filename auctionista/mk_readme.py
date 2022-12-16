import app
from inspect import cleandoc
def mk_endpoint_md(route, methods, func):
    route_str = route \
                .replace('<', r'\<') \
                .replace('>', r'\>')
    s = f'### {route_str}'
    s += f' ({", ".join(methods)})'

    # we're going to make the naive assumption
    # that any decorated route is decorated because it's a protected view.
    # Ideally, we'd check this with reflection. But I'm lazy right now.
    if hasattr(func, '__wrapped__'):
        s += '\n*login required*\n'

    s += f'\n{cleandoc(func.__doc__)}'

    return s

docs = '\n\n'.join(
    mk_endpoint_md(
        route=str(rule), 
        methods=rule.methods - {'OPTIONS', 'HEAD'},
        func=getattr(app, rule.endpoint)) 
    for rule in app.app.url_map.iter_rules()
    if rule.endpoint != 'static')

with open('README_stub.md', 'r') as f:
    print(f.read() + f'\n\n## API Usage\n\n{docs}')

