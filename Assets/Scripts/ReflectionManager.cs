﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ReflectionManager : MonoBehaviour
{
    [SerializeField] Material lake_material;
    [SerializeField] Renderer lake_renderer;

    private void Start() {
        main_camera = Camera.main;
        RenderPipelineManager.endCameraRendering += AfterCameraRender;

        GameObject reflection_camera_go = new GameObject("ReflectionCamera");
        reflection_camera = reflection_camera_go.AddComponent<Camera>();

        render_texture = new RenderTexture(Screen.width, Screen.height, 24);
        reflection_camera.CopyFrom(main_camera);

        lake_renderer.sharedMaterial.SetTexture("_ReflectionTex", render_texture);
    }

    private void AfterCameraRender(ScriptableRenderContext _render_context, Camera _camera) {
        if (_camera == main_camera && reflection_camera != null) {
            RenderReflection();
        }
    }

    private void RenderReflection() {
        reflection_camera.targetTexture = render_texture;

        Vector3 camera_direction_world_space = main_camera.transform.forward;
        Vector3 camera_up_world_space = main_camera.transform.up;
        Vector3 camera_position_world_space = main_camera.transform.position;

        Vector3 camera_direction_plane_space = reflection_plane.InverseTransformDirection(camera_direction_world_space);
        Vector3 camera_up_plane_space = reflection_plane.InverseTransformDirection(camera_up_world_space);
        Vector3 camera_position_plane_space = reflection_plane.InverseTransformPoint(camera_position_world_space);

        camera_direction_plane_space.y *= -1f;
        camera_up_plane_space.y *= -1f;
        camera_position_plane_space.y *= -1f;

        camera_direction_world_space = reflection_plane.TransformDirection(camera_direction_plane_space );
        camera_up_world_space = reflection_plane.TransformDirection(camera_up_plane_space );
        camera_position_world_space = reflection_plane.TransformPoint(camera_position_plane_space );

        reflection_camera.transform.LookAt(reflection_camera.transform.position + camera_direction_world_space, camera_up_world_space);
        reflection_camera.transform.position = camera_position_world_space;

        Vector3 normal = reflection_plane.up;
        Vector4 plane = new Vector4(normal.x, normal.y, normal.z, -Vector3.Dot(normal, reflection_plane.position));

        Matrix4x4 cam_matrix = reflection_camera.worldToCameraMatrix.inverse.transpose;
        
        reflection_camera.projectionMatrix = reflection_camera.CalculateObliqueMatrix(cam_matrix * plane);
        
        // DrawQuad();
    }
    private void DrawQuad() {
        GL.PushMatrix();

        reflection_material.SetPass(0);
        reflection_material.SetTexture("_ReflectionMap", render_texture);

        GL.LoadOrtho();
        GL.Begin(GL.QUADS);

        GL.TexCoord2(1f, 0f);
        GL.Vertex3(0f, 0f, 0f);

        GL.TexCoord2(1f, 1f);
        GL.Vertex3(0f, 1f, 0f);

        GL.TexCoord2(0f, 1f);
        GL.Vertex3(1f, 1f, 0f);

        GL.TexCoord2(0f, 0f);
        GL.Vertex3(1f, 0f, 0f);

        GL.End();
        
        GL.PopMatrix();
    }

    RenderTexture render_texture;

    [SerializeField] Material reflection_material;
    Camera reflection_camera;
    [SerializeField] Camera main_camera;
    [SerializeField] Transform reflection_plane;
}