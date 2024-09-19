import glob
import os
import sys
import wandb
import numpy as np

WANDB_NAME="sbhambr1"
POLICY_POOL_PATH = "hsp/policy_pool"
RESULT_PATH = "hsp/scripts/results/Overcooked/{layout}/mappo/sp/wandb"

def extract_sp_S1_models(layout):
    wandb_dir = RESULT_PATH.format(layout=layout)
    runs = glob.glob(f"{wandb_dir}/run*")
    run_ids = [x.split('-')[-1] for x in runs]
    print(run_ids)
    api = wandb.Api()
    i = 0
    for run_id in run_ids:
        try:
            run = api.run(f"{WANDB_NAME}/Overcooked/{run_id}")
        except:
            print(f"Run {run_id} not found")
            continue
        if run.state == "finished":
            i += 1
            final_ep_sparse_r = run.summary['ep_sparse_r']
            history = run.history()
            history = history[['_step', 'ep_sparse_r']]
            steps = history['_step'].to_numpy()
            ep_sparse_r = history['ep_sparse_r'].to_numpy()
            for run in runs:
                if run_id in run:
                    file_dir = glob.glob(f"{run}/*")
                   
            for file_path in file_dir:
                if 'files' in file_path:
                    ckpt_files = glob.glob(f"{file_path}/*") 
            
            actor_pts = [f for f in ckpt_files if f.split('/')[-1].startswith('actor_periodic')]
            
            if actor_pts == []:
                print(f"Run {run_id} has no actor checkpoints")
                continue
            actor_versions = [eval(f.split('_')[-1].split('.pt')[0]) for f in actor_pts]
            actor_pts = {v: p for v, p in zip(actor_versions, actor_pts)}
            actor_versions = sorted(actor_versions)
            max_actor_versions = max(actor_versions) + 1
            max_steps = max(steps)

            new_steps = [steps[0]]
            new_ep_sparse_r = [ep_sparse_r[0]]
            for s, er in zip(steps[1:], ep_sparse_r[1:]):
                s = int(s)
                l_s = int(new_steps[-1])
                l_er = int(new_ep_sparse_r[-1])
                for w in range(l_s + 1, s, 100):
                    new_steps.append(w)
                    new_ep_sparse_r.append(l_er + (er - l_er) * (w - l_s) / (s - l_s))
            steps = new_steps
            ep_sparse_r = new_ep_sparse_r

            # select checkpoints
            selected_pts = dict(init=0, mid=-1, final=max_steps)
            mid_ep_sparse_r = final_ep_sparse_r / 2
            min_delta = 1e9
            for s, score in zip(steps, ep_sparse_r):
                if min_delta > abs(mid_ep_sparse_r - score):
                    min_delta = abs(mid_ep_sparse_r - score)
                    selected_pts["mid"] = s

            selected_pts = {k: int(v / max_steps * max_actor_versions) for k, v in selected_pts.items()}
            for tag, exp_version in selected_pts.items():
                version = actor_versions[0]
                for actor_version in actor_versions:
                    if abs(exp_version - version) > abs(exp_version - actor_version):
                        version = actor_version
                print(f"sp{i}", tag, "Expected", exp_version, "Found", version)
                ckpt = actor_pts[version]
                fcp_s1_dir = f"{POLICY_POOL_PATH}/{layout}/fcp/s1"
                os.system(f"mv {ckpt} {fcp_s1_dir}/sp{i}_{tag}_actor.pt")


if __name__ == "__main__":
    layout = sys.argv[1]
    assert layout in ["random1", "random3", "unident_s", "distant_tomato", "many_orders", "all"]
    if layout == "all":
        for layout in ["random1", "random3", "unident_s", "distant_tomato", "many_orders"]:
            extract_sp_S1_models(layout)
    else:
        extract_sp_S1_models(layout)
