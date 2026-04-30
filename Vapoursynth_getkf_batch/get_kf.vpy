from vapoursynth import core
import vapoursynth as vs

def gen_kf(input: vs.VideoNode, output="keyframes.txt", mode='wwxd', mode2='aegi', dh=360):
    '''Generate keyframes from video by wwxd or scxvid'''
    funcName = 'gen_kf'
    dw = input.width * dh // input.height
    src = input.resize.Bilinear(dw,dh,format=vs.YUV420P8) if input.format.id != vs.YUV420P8 else input.resize.Bilinear(dw,dh)
    if mode == 'wwxd':
        clip = src.wwxd.WWXD()
        opt_txt = "# keyframe format v1\nfps 0\n" if mode2 == 'aegi' else ""
        for i in range(clip.num_frames):
            if clip.get_frame(i).props.Scenechange == 1:
                opt_txt += f"{i}\n" if mode2 == 'aegi' else f"{i} I\n"
            if i % 1000 == 0:
                print(i)
        text_file = open(output,"w")
        text_file.write(opt_txt)
        text_file.close()
    elif mode == 'scxvid':
        clip = src.scxvid.Scxvid(log=output)
    else:
        raise TypeError(f'{funcName}: "mode must be wwxd or scxvid')
    return clip


input = str(name, encoding = "utf-8") if vs.__api_version__.api_major < 4 else name
src = core.lsmas.LWLibavSource(input,threads=0)
last = gen_kf(src, input+".kf.txt")
src.set_output(0)
